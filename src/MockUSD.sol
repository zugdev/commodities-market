// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockUSD is ERC20, Ownable {
    constructor() ERC20("Mock USD", "mUSD") Ownable(msg.sender){}

    // Mint new tokens 
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
