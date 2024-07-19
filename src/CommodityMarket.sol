// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CommodityToken.sol";
import "./MockUSD.sol";

interface IOpenOracleCommonDataFeed {
    function latestRoundData(uint8 taskType) external view returns (bytes memory result, uint256 sd, uint256 timestamp, uint32 startBlock, uint32 endBlock);
    function requestNewReport(uint8 taskType) external;
}

contract CommodityMarket is Ownable {
    IOpenOracleCommonDataFeed public priceFeed;
    MockUSD public mockUSD;

    mapping(uint8 => CommodityToken) public commodityTokens;
    uint256 public mintingFee = 1; // 1% fee for minting
    uint256 public burningFee = 1; // 1% fee for burning

    uint256 public totalUSDInLiquidity;
    mapping(address => uint256) public usdLiquidity;
    mapping(address => uint256) public accruedFees;
    address[] public liquidityProviders;

    constructor(address _priceFeed, address _mockUSD) Ownable(msg.sender){
        priceFeed = IOpenOracleCommonDataFeed(_priceFeed);
        mockUSD = MockUSD(_mockUSD);
    }

    function createCommodityToken(string memory name, string memory symbol, uint8 taskType) external onlyOwner {
        require(address(commodityTokens[taskType]) == address(0), "Token already exists for this commodity");
        CommodityToken token = new CommodityToken(name, symbol, taskType);
        commodityTokens[taskType] = token;
    }

    function mintCommodity(uint8 taskType, address to, uint256 amount) external {
        CommodityToken token = commodityTokens[taskType];
        require(address(token) != address(0), "Commodity token does not exist");

        uint256 priceInUSD = getLatestPrice(taskType);
        uint256 totalUSD = amount * priceInUSD;
        uint256 fee = totalUSD * mintingFee / 100;
        uint256 netUSD = totalUSD + fee;

        // Transfer USD from the user to this contract
        require(mockUSD.transferFrom(to, address(this), netUSD), "USD transfer failed");

        // Add fee to liquidity pool
        totalUSDInLiquidity += fee;

        token.mint(to, amount);
    }

    function burnCommodity(uint8 taskType, address from, uint256 amount) external onlyOwner {
        CommodityToken token = commodityTokens[taskType];
        require(address(token) != address(0), "Commodity token does not exist");

        uint256 priceInUSD = getLatestPrice(taskType);
        uint256 totalUSD = amount * priceInUSD;
        uint256 fee = totalUSD * burningFee / 100;

        // Add fee to liquidity pool
        totalUSDInLiquidity += fee;

        token.burn(from, amount);

        // Transfer the corresponding amount of USD back to the user
        require(mockUSD.transfer(from, totalUSD - fee), "USD transfer failed");
    }

    function requestPriceUpdate(uint8 taskType) external onlyOwner {
        priceFeed.requestNewReport(taskType);
    }

    function getLatestPrice(uint8 taskType) public view returns (uint256 price) {
        (bytes memory result, , , , ) = priceFeed.latestRoundData(taskType);
        price = abi.decode(result, (uint256));
    }

    function setMintingFee(uint256 newFee) external onlyOwner {
        mintingFee = newFee;
    }

    function setBurningFee(uint256 newFee) external onlyOwner {
        burningFee = newFee;
    }

    function supplyUSDLiquidity(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer USD from the user to this contract
        require(mockUSD.transferFrom(msg.sender, address(this), amount), "USD transfer failed");

        if (usdLiquidity[msg.sender] == 0) {
            liquidityProviders.push(msg.sender);
        }

        usdLiquidity[msg.sender] += amount;
        totalUSDInLiquidity += amount;
    }

    function withdrawUSDLiquidity(uint256 amount) external {
        require(usdLiquidity[msg.sender] >= amount, "Insufficient liquidity");

        usdLiquidity[msg.sender] -= amount;
        totalUSDInLiquidity -= amount;

        if (usdLiquidity[msg.sender] == 0) {
            removeLiquidityProvider(msg.sender);
        }

        require(mockUSD.transfer(msg.sender, amount), "USD transfer failed");
    }

    function distributeFees() external onlyOwner {
        require(totalUSDInLiquidity > 0, "No liquidity available");

        uint256 totalFees = mintingFee + burningFee;
        for (uint256 i = 0; i < liquidityProviders.length; i++) {
            address provider = liquidityProviders[i];
            uint256 providerLiquidity = usdLiquidity[provider];
            uint256 providerShare = (providerLiquidity * totalFees) / totalUSDInLiquidity;
            accruedFees[provider] += providerShare;
        }

        totalFees = 0; // Reset total fees after distribution
    }

    function claimFees() external {
        uint256 fees = accruedFees[msg.sender];
        require(fees > 0, "No fees to claim");

        accruedFees[msg.sender] = 0;
        require(mockUSD.transfer(msg.sender, fees), "USD transfer failed");
    }

    function viewAccruedFees(address user) external view returns (uint256) {
        return accruedFees[user];
    }

    function removeLiquidityProvider(address provider) internal {
        for (uint256 i = 0; i < liquidityProviders.length; i++) {
            if (liquidityProviders[i] == provider) {
                liquidityProviders[i] = liquidityProviders[liquidityProviders.length - 1];
                liquidityProviders.pop();
                break;
            }
        }
    }
}
