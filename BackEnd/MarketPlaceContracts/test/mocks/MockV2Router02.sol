// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract MockV2Router02 {

    function swapExactTokensForTokens(uint amountIn, uint, address[] calldata path, address to,uint) external returns (uint[] memory amounts) {

        // Simulamos salida 1:1
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        amounts[path.length - 1] = amountIn;

        // Mint fake token out
        (bool ok,) = path[path.length - 1].call(
            abi.encodeWithSignature("mint(address,uint256)", to, amountIn)
        );
        require(ok, "mock mint failed");
    }
}
