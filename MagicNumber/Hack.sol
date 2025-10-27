// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Hack {
    constructor() {
        // runtime = returns 0x...002a as bytes32
        bytes memory runtime = hex"602a60005260206000f3";
        assembly {
            return(add(runtime, 0x20), mload(runtime))
        }
    }
}
