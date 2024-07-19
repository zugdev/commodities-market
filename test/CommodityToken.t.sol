// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CommodityToken.sol";

contract CommodityTokenTest is Test {
    CommodityToken commodityToken;
    address owner = address(this);

    function setUp() public {
        commodityToken = new CommodityToken("Gold Token", "GLD", 1);
    }

    function testMint() public {
        uint256 mintAmount = 1000 * 1e18;
        commodityToken.mint(owner, mintAmount);
        assertEq(commodityToken.balanceOf(owner), mintAmount);
    }

    function testBurn() public {
        uint256 mintAmount = 1000 * 1e18;
        commodityToken.mint(owner, mintAmount);

        uint256 burnAmount = 500 * 1e18;
        commodityToken.burn(owner, burnAmount);
        assertEq(commodityToken.balanceOf(owner), mintAmount - burnAmount);
    }
}
