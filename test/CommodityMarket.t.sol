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
        
        mockUSD.mint(user, 100000 * 1e18);
        vm.prank(user);
        mockUSD.approve(address(commodityMarket), 100000 * 1e18);

        commodityMarket.createCommodityToken("Gold Token", "GLD", 1);
        console.log("owner ", commodityMarket.commodityTokens(1).owner());
        console.log("commodityMarket ", address(commodityMarket));

        // Seed some initial liquidity
        uint256 initialLiquidity = 50000 * 1e18;
        vm.prank(user);
        commodityMarket.supplyUSDLiquidity(initialLiquidity);
    }

    function testOracle() public view {
        (bytes memory result,,,,) = commodityMarket.priceFeed().latestRoundData(1);
        assertTrue(result.length > 0);
    }

    function testLatestPrice() public view {
        uint256 price = commodityMarket.getLatestPrice(1);
        assertTrue(price > 0);
        console.log("price ",price);
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
        assertTrue(mockUSD.balanceOf(user) > initialBalance - 1e6 /*fee*/);
    }

    function testSupplyAndWithdrawUSDLiquidity() public {
        uint256 supplyAmount = 100 * 1e18;

        vm.prank(user);
        commodityMarket.supplyUSDLiquidity(supplyAmount);
        assertEq(commodityMarket.usdLiquidity(user), supplyAmount + 50000 * 1e18);

        vm.prank(user);
        commodityMarket.withdrawUSDLiquidity(supplyAmount);
        assertEq(commodityMarket.usdLiquidity(user), 50000 * 1e18);
    }

    function testDistributeAndClaimFees() public {
        uint256 supplyAmount = 100 * 1e18;

        vm.prank(user);
        commodityMarket.supplyUSDLiquidity(supplyAmount);

        // Simulate some fees being accrued
        vm.prank(user);
        commodityMarket.mintCommodity(1, user, 1);
        vm.prank(user);
        commodityMarket.burnCommodity(1, user, 1);

        vm.prank(owner);
        commodityMarket.distributeFees();

        uint256 accruedFees = commodityMarket.viewAccruedFees(user);
        assertTrue(accruedFees > 0);

        uint256 initialBalance = mockUSD.balanceOf(user);

        vm.prank(user);
        commodityMarket.claimFees();

        assertTrue(mockUSD.balanceOf(user) > initialBalance);
    }
}
