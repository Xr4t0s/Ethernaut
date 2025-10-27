// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;  // ou ^0.8.25

import {Test, console} from "forge-std/Test.sol";

interface IMotorbike {}
interface IEngine {
    function initialize() external;
    function upgradeToAndCall(address newImplementation, bytes calldata data) external payable;
    function upgrader() external view returns (address);
}

contract CounterTest is Test {
	address player = makeAddr("xH4ck3r");
	address engine;
	address bike;
	IEngine ie;
	IEngine ib;

	function deploy(bytes memory code) internal returns (address addr) {
		assembly {
			addr := create(0, add(code, 0x20), mload(code))
		}
		require(addr != address(0), "create failed");
	}

	function setUp() public {
		// Récupère le bytecode compilé avec son propre pragma 0.6.12
		bytes memory engineCode    = vm.getCode("src/Target.sol:Engine");
		engine = deploy(engineCode);

		// Constructor de Motorbike prend l'impl address (engine)
		bytes memory bikeCode = vm.getCode("src/Target.sol:Motorbike");
		// Encoder le constructor( address _logic )
		bytes memory bikeCreation = abi.encodePacked(bikeCode, abi.encode(engine));
		bike = deploy(bikeCreation);

		// Utilise des interfaces côté test
		ie = IEngine(bike);
		ib = IEngine(engine);
	}

	function test_ok() public {
		console.log(address(uint160(0)));
		console.log('Starting...');
		vm.startPrank(player);
		vm.deal(player, 1 ether);
		vm.expectRevert();
		ie.upgradeToAndCall{value: 0.001 ether}(address(0), "");
		vm.expectRevert();
		ie.initialize();
		ib.initialize();
	}
}
