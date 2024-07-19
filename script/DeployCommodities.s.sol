// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/MockUSD.sol";
import "../src/CommodityMarket.sol";
import "../src/CommodityToken.sol";

contract DeployCommodities is Script {
    address priceFeedAddress = 0xB233eE56e57f7eB1B1144b28214Abc74b273d3D5;

    function run() external {
        vm.startBroadcast();

        // Deploy MockUSD contract
        MockUSD mockUSD = new MockUSD();
        console.log("MockUSD deployed at:", address(mockUSD));

        // Deploy CommodityMarket contract
        CommodityMarket commodityMarket = new CommodityMarket(priceFeedAddress, address(mockUSD));
        console.log("CommodityMarket deployed at:", address(commodityMarket));

        // Create commodity tokens
        string[14] memory tokenNames = [
            "Oil Token", "Gold Token", "Silver Token", "Platinum Token", "Palladium Token",
            "Copper Token", "Rbob Gas Token", "Natural Gas Token", "Brent Crude Oil Token", "Corn Token",
            "Soybean Token", "Rough Rice Token", "Cocoa Token", "Lumber Token"
        ];
        string[14] memory tokenSymbols = [
            "OIL", "GLD", "SLV", "PLT", "PLD",
            "CPR", "RBOB", "NG", "BRNT", "CRN",
            "SBN", "RR", "CCA", "LMBR"
        ];

        for (uint8 i = 0; i < tokenNames.length; i++) {
            commodityMarket.createCommodityToken(tokenNames[i], tokenSymbols[i], i);
            console.log(string(abi.encodePacked(tokenNames[i], " created with symbol ", tokenSymbols[i])));
        }

        vm.stopBroadcast();
    }
}
