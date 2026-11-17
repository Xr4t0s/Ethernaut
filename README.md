# Ethernaut — Smart contract exploits

My solutions to [OpenZeppelin Ethernaut](https://ethernaut.openzeppelin.com/), a wargame of vulnerable Solidity contracts.
Each folder holds the target contract, my exploit contract, and the script or Foundry test used to run the attack.

## Levels

| Level | Vulnerability class | Exploit |
|-------|--------------------|---------|
| [Coin Flip](CoinFlip) | Predictable randomness from `blockhash` (10 wins, one per block) | `script.sh` |
| [Telephone](Telephone) | `tx.origin` vs `msg.sender` authentication | Foundry test |
| [Privacy](Privacy) | "Private" storage read directly from slots | `exploit.sh` |
| [GateKeeper One](GateKeeper1) | `gasleft()` brute force and type-casting checks | `Hack.sol` + `exploit.sh` |
| [GateKeeper Two](GateKeeper2) | `extcodesize` bypass from a constructor, XOR key | `Hack.sol` + `exploit.sh` |
| [GateKeeper Three](GateKeeper3) | Misnamed constructor, storage read, failing `send` | Foundry test |
| [Naught Coin](NaughtCoin) | ERC20 time lock bypassed with `approve` + `transferFrom` | `Hack.sol` |
| [Preservation](Preservation) | `delegatecall` storage collision | `Hack.sol` + `script.sh` |
| [Recovery](Recovery) | Recomputing a `CREATE` address to recover lost funds | `script.sh` |
| [Magic Number](MagicNumber) | Writing raw EVM bytecode (≤ 10 opcodes) | `Hack.sol` + `script.sh` |
| [Alien Codex](AlienCodex) | Dynamic array length underflow → arbitrary storage write | `Hack.sol` + `script.sh` |
| [Denial](Denial) | Gas griefing through an unbounded external call | `Hack.sol` + `script.sh` |
| [Shop](Shop) | Trusting a `view` function from an untrusted caller | `Hack.sol` |
| [Dex](Dex) | Price manipulation on a naive AMM | target only |
| [Dex Two](DexTwo) | Missing token validation in `swap` | `Hack.sol` |
| [Puzzle Wallet](PuzzleWallet) | Proxy storage collision + nested `multicall` | `Hack.sol`, [write-up](PuzzleWallet/POC.md) |
| [Motorbike](Motorbike) | Uninitialized UUPS implementation → `selfdestruct` | Foundry test |
| [DoubleEntryPoint](DoubleEntryPoint) | Writing a Forta detection bot for a delegated token | Foundry test |
| [Good Samaritan](GoodSamaritan) | Spoofing a custom error to trigger a fallback path | Foundry test |
| [Switch](Switch) | Hand-crafted calldata with shifted ABI offsets | Foundry test |
| [Higher Order](HigherOrder) | Dirty high-order bits in calldata (`uint8` cast) | Foundry test |
| [Stake](Stake) | Unchecked `transferFrom` return value | Foundry test |

## Running

The folders with a `foundry.toml` are [Foundry](https://book.getfoundry.sh/) projects. Dependencies aren't committed, so install them first:

```bash
cd Motorbike
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-git
forge test -vvv
```

The other levels use [`cast`](https://book.getfoundry.sh/cast/) scripts against a live instance:

```bash
./script.sh <RPC_URL> <INSTANCE_ADDRESS> <PRIVATE_KEY>
```

> Only use a throwaway testnet key.

## Stack

Solidity · Foundry (forge / cast) · EVM storage layout · proxy patterns
