// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CommodityToken is ERC20, Ownable {
    uint8 public taskType; // Commodity type (e.g., 1 for Gold)

    constructor(string memory name, string memory symbol, uint8 _taskType) ERC20(name, symbol) Ownable(msg.sender) {
        taskType = _taskType;
    }

    // Mint new tokens (only owner can mint, which should be a managing contract)
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Burn tokens
    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}
