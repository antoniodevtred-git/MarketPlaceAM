// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC20(name_, symbol_) {}

    /// @notice Mint libre SOLO para tests
    function mint(address to_, uint256 amount_) external {
        _mint(to_, amount_);
    }
}
