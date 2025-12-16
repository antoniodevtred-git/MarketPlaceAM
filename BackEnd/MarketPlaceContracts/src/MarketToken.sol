// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract MarketToken is ERC20, Ownable {

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_
    ) ERC20(name_, symbol_) Ownable(owner_) {
        // Mint inicial solo para pruebas
        _mint(owner_, 1_000_000 * 1e18);
    }

    
    function mint(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "12");
        require(amount > 0, "13");

        _mint(to, amount);
    }
}
