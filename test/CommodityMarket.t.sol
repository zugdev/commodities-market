// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/CommodityMarket.sol";
import "../src/MockUSD.sol";
import "../src/CommodityToken.sol";

contract CommodityMarketTest is Test {
    MockUSD mockUSD;
    CommodityMarket commodityMarket;
    address owner = address(this);
    address user = address(0x1);

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("holesky"));
        mockUSD = new MockUSD();
        commodityMarket = new CommodityMarket(0xB233eE56e57f7eB1B1144b28214Abc74b273d3D5, address(mockUSD)); // Use appropriate price feed address

        mockUSD.mint(user, 1000 * 1e18);
        vm.prank(user);
        mockUSD.approve(address(commodityMarket), 1000 * 1e18);

        commodityMarket.createCommodityToken("Gold Token", "GLD", 1);
    }

    function testMintCommodity() public {
        uint256 mintAmount = 1;
        uint256 initialBalance = mockUSD.balanceOf(user);

        vm.prank(user);
        commodityMarket.mintCommodity(1, user, mintAmount);

        CommodityToken token = commodityMarket.commodityTokens(1);
        assertEq(token.balanceOf(user), mintAmount);
        assertTrue(mockUSD.balanceOf(address(commodityMarket)) > 0);
        assertTrue(mockUSD.balanceOf(user) < initialBalance);
    }

    function testBurnCommodity() public {
        uint256 mintAmount = 1;
        uint256 initialBalance = mockUSD.balanceOf(user);

        vm.prank(user);
        commodityMarket.mintCommodity(1, user, mintAmount);

        CommodityToken token = commodityMarket.commodityTokens(1);
        assertEq(token.balanceOf(user), mintAmount);

        vm.prank(user);
        commodityMarket.burnCommodity(1, user, mintAmount);

        assertEq(token.balanceOf(user), 0);
        assertTrue(mockUSD.balanceOf(user) > initialBalance);
    }

    function testSupplyAndWithdrawUSDLiquidity() public {
        uint256 supplyAmount = 100 * 1e18;

        vm.prank(user);
        commodityMarket.supplyUSDLiquidity(supplyAmount);
        assertEq(commodityMarket.usdLiquidity(user), supplyAmount);

        vm.prank(user);
        commodityMarket.withdrawUSDLiquidity(supplyAmount);
        assertEq(commodityMarket.usdLiquidity(user), 0);
        assertEq(mockUSD.balanceOf(user), 1000 * 1e18);
    }

    function testDistributeAndClaimFees() public {
        uint256 supplyAmount = 100 * 1e18;

        vm.prank(user);
        commodityMarket.supplyUSDLiquidity(supplyAmount);

        // Simulate some fees being accrued
        commodityMarket.mintCommodity(1, user, 10000);
        commodityMarket.burnCommodity(1, user, 10000);

        commodityMarket.distributeFees();

        uint256 accruedFees = commodityMarket.viewAccruedFees(user);
        assertTrue(accruedFees > 0);

        vm.prank(user);
        commodityMarket.claimFees();
        assertTrue(mockUSD.balanceOf(user) > 1000 * 1e18);
    }
}
