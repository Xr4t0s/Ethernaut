// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HackUtil {
	uint256 i = 0;

	function increment() public returns (bool, bytes memory) {
		if (i == 0) {
			i++;
			return (true, bytes("101"));
		}
		return (true, bytes("99"));
	}
}