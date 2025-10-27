// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test,console} from "forge-std/Test.sol";
import {Stake} from "../src/Target.sol";
import {Hack} from "../src/Hack.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockWETH is Test, ERC20 {
    constructor() ERC20("Wrapped ETH", "WETH") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

contract CounterTest is Test {
	address public player = makeAddr("0xHacker");
	address public admin = makeAddr("0xAdmin");
	MockWETH weth;
	Stake stake;

	function setUp() public {
		vm.startPrank(admin);
		weth = new MockWETH();
		stake = new Stake(address(weth));
		vm.deal(player, 100 ether);
		vm.stopPrank();
	}

	// function test_checks() public {
	// 	vm.startPrank(player);
	// 	(,bytes memory allowance) = address(WETH).call(abi.encodeWithSelector(0x095ea7b3, address(stake), 10));
	// 	stake.StakeWETH(uint256(1 ether));
	// 	assertEq(stake.UserStake(player), 1 ether);
	// 	assertTrue(stake.Stakers(player));
	// 	uint256 amount_staked = stake.totalStaked();
	// 	uint256 amount_contract = address(stake).balance;
	// 	console.log(amount_contract);
	// 	assertFalse(amount_staked > amount_contract);
	// 	// payable(address(stake)).send(1 ether);
	// 	assertTrue(amount_staked > amount_contract);
	// }

	function test_hack() public {
		vm.startPrank(player);
		Hack hack = new Hack(address(stake), address(weth));
		weth.mint(address(hack), 1e18);
		(bool ok,) = address(hack).call{value: 0.0022 ether}("");
		hack.attack();
		
		assertNotEq(address(stake).balance, 0);
		assertTrue(stake.Stakers(address(hack)));
		console.log(stake.totalStaked());
		assert(stake.UserStake(address(hack)) == 0);
		assert(stake.totalStaked() > 0);
	}
}
