// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/MockUSD.sol";

contract MockUSDTest is Test {
    MockUSD mockUSD;
    address owner = address(this);

    function setUp() public {
        mockUSD = new MockUSD();
    }

    function testMint() public {
        uint256 mintAmount = 1000 * 1e18;
        mockUSD.mint(owner, mintAmount);
        assertEq(mockUSD.balanceOf(owner), mintAmount);
    }

    function testTransfer() public {
        uint256 mintAmount = 1000 * 1e18;
        mockUSD.mint(owner, mintAmount);

        address recipient = address(0x1);
        uint256 transferAmount = 500 * 1e18;
        mockUSD.transfer(recipient, transferAmount);
        assertEq(mockUSD.balanceOf(recipient), transferAmount);
        assertEq(mockUSD.balanceOf(owner), mintAmount - transferAmount);
    }

    function testApproveAndTransferFrom() public {
        uint256 mintAmount = 1000 * 1e18;
        mockUSD.mint(owner, mintAmount);

        address spender = address(0x2);
        uint256 approveAmount = 500 * 1e18;
        mockUSD.approve(spender, approveAmount);
        assertEq(mockUSD.allowance(owner, spender), approveAmount);

        vm.prank(spender);
        mockUSD.transferFrom(owner, spender, approveAmount);
        assertEq(mockUSD.balanceOf(spender), approveAmount);
        assertEq(mockUSD.balanceOf(owner), mintAmount - approveAmount);
    }
}
