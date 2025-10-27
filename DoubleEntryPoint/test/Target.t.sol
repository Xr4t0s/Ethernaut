// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/Target.sol";

contract AlertBot is IDetectionBot {
	Forta forta;
	address player;
	address vault;

	constructor(address _forta, address _player, address _vault) {
		forta = Forta(_forta);
		player = _player;
		vault = _vault;
	}

	function handleTransaction(address user, bytes calldata msgData) public {
		(address to, uint256 value, address origSender) = abi.decode(msgData[4:], (address,uint256,address));
		if (origSender == vault)
			forta.raiseAlert(player);
	}
}

contract DoubleEntryPointTest is Test, ERC20("DoubleEntryPointToken", "DET"), Ownable(msg.sender) {
	address player = makeAddr("0xPLAYER");
	address admin = makeAddr("0xADMIN");
	LegacyToken token;
	Forta forta;
	CryptoVault vault;
	DoubleEntryPoint target;
	AlertBot myBot;


    function setUp() public {
		vm.startPrank(admin);
		vm.deal(admin, 100 ether);
		token = new LegacyToken();
		forta = new Forta();
		vault = new CryptoVault(address(token));
		target = new DoubleEntryPoint(address(token), address(vault), address(forta), player);
		token.mint(address(vault), 100 ether);
		vault.setUnderlying(address(target));
		token.delegateToNewContract(target);
		vm.stopPrank();
		console.log('Setup finished, starting tests...');
    }

	function test_rugpull_legacy() public {
		vm.startPrank(player);
		target.balanceOf(address(vault));
		vault.sweepToken(token);
		target.balanceOf(address(vault));
		vm.stopPrank();
	}

	function test_rugpull_interruption() public {
		vm.startPrank(player);
		myBot = new AlertBot(address(forta), player, address(vault));
		forta.setDetectionBot(address(myBot));
		target.balanceOf(address(vault));
		vault.sweepToken(token);
		target.balanceOf(address(vault));
		vm.stopPrank();
	}
}
