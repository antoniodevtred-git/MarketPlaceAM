// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IV2Router02.sol";

contract MarketSwap is Ownable {
    using SafeERC20 for IERC20;

    IV2Router02 public immutable router;
    address public immutable marketToken;

    event TokensSwapped(address indexed user_, address indexed tokenIn_, uint256 amountIn_, uint256 amountOut_);

    constructor(address router_, address marketToken_, address owner_) Ownable(owner_) {
        require(router_ != address(0), "12");
        require(marketToken_ != address(0), "14");

        router = IV2Router02(router_);
        marketToken = marketToken_;
    }

    function swapToMarketToken(address tokenIn_, uint256 amountIn_, uint256 amountOutMin_, address[] calldata path_, uint256 deadline_) external {
        require(tokenIn_ != address(0), "14");
        require(amountIn_ > 0, "13");
        require(path_.length >= 2, "14");
        require(path_[path_.length - 1] == marketToken, "14");
        require(deadline_ >= block.timestamp, "19");

        // Pull tokens from user
        IERC20(tokenIn_).safeTransferFrom(
            msg.sender,
            address(this),
            amountIn_
        );

        // Approve router
        IERC20(tokenIn_).forceApprove(address(router), amountIn_);

        // Swap
        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn_,
            amountOutMin_,
            path_,
            msg.sender,
            deadline_
        );

        emit TokensSwapped(msg.sender, tokenIn_, amountIn_, amounts[amounts.length - 1]);
    }
}
