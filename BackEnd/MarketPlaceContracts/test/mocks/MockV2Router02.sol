// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract MockV2Router02 {

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint /* deadline */
    ) external returns (uint[] memory amounts) {

        require(path.length >= 2, "INVALID_PATH");

        address tokenIn = path[0];
        address tokenOut = path[path.length - 1];

        // Pull tokenIn from caller (MarketSwap)
        IERC20(tokenIn).transferFrom(
            msg.sender,
            address(this),
            amountIn
        );

        // Simple 1:1 mock swap
        uint amountOut = amountIn;
        require(amountOut >= amountOutMin, "INSUFFICIENT_OUTPUT");

        // Send tokenOut to user
        IERC20(tokenOut).transfer(to, amountOut);

        // Build amounts array
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        amounts[path.length - 1] = amountOut;
    }
}
