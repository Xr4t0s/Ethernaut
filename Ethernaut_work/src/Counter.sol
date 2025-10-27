// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Counter {
    constructor(address payable _target) payable public {
        (bool success,) = _target.call{value: msg.value, gas:200000}("");
    	require(success, "failed to construct");
    }
}
