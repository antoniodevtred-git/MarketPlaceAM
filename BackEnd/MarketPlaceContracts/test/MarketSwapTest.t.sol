// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/MarketSwap.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockV2Router02.sol";

contract MarketSwapTest is Test {

    MarketSwap swap;
    MockERC20 tokenIn;
    MockERC20 marketToken;
    MockV2Router02 router;

    address owner = address(1);
    address user  = address(2);

    function setUp() public {
        router = new MockV2Router02();

        tokenIn = new MockERC20("Token In", "TIN");
        marketToken = new MockERC20("Market Token", "MKT");

        swap = new MarketSwap(
            address(router),
            address(marketToken),
            owner
        );

        tokenIn.mint(user, 1_000 ether);

        vm.prank(user);
        tokenIn.approve(address(swap), type(uint256).max);
    }

    // ------------------------------------------------------------
    // SUCCESS
    // ------------------------------------------------------------

    function testSwapWorks() public {
        address;
        path[0] = address(tokenIn);
        path[1] = address(marketToken);

        uint256 beforeBal = marketToken.balanceOf(user);

        vm.prank(user);
        swap.swapToMarketToken(
            address(tokenIn),
            100 ether,
            0,
            path,
            block.timestamp + 1
        );

        uint256 afterBal = marketToken.balanceOf(user);
        assertEq(afterBal - beforeBal, 100 ether);
    }

    function testSwapEmitsEvent() public {
        address;
        path[0] = address(tokenIn);
        path[1] = address(marketToken);

        vm.expectEmit(true, true, false, true);
        emit MarketSwap.TokensSwapped(
            user,
            address(tokenIn),
            100 ether,
            100 ether
        );

        vm.prank(user);
        swap.swapToMarketToken(
            address(tokenIn),
            100 ether,
            0,
            path,
            block.timestamp + 1
        );
    }

    // ------------------------------------------------------------
    // REVERTS
    // ------------------------------------------------------------

    function testRevertIfAmountZero() public {
        address;
        path[0] = address(tokenIn);
        path[1] = address(marketToken);

        vm.prank(user);
        vm.expectRevert(bytes("13"));
        swap.swapToMarketToken(
            address(tokenIn),
            0,
            0,
            path,
            block.timestamp
        );
    }

    function testRevertIfTokenInZero() public {
        address;
        path[0] = address(0);
        path[1] = address(marketToken);

        vm.prank(user);
        vm.expectRevert(bytes("14"));
        swap.swapToMarketToken(
            address(0),
            1 ether,
            0,
            path,
            block.timestamp
        );
    }

    function testRevertIfPathTooShort() public {
        address;
        path[0] = address(tokenIn);

        vm.prank(user);
        vm.expectRevert(bytes("14"));
        swap.swapToMarketToken(
            address(tokenIn),
            1 ether,
            0,
            path,
            block.timestamp
        );
    }

    function testRevertIfPathDoesNotEndInMarketToken() public {
    
        path[0] = address(tokenIn);
        path[1] = address(tokenIn);

        vm.prank(user);
        vm.expectRevert(bytes("14"));
        swap.swapToMarketToken(
            address(tokenIn),
            1 ether,
            0,
            path,
            block.timestamp
        );
    }
}
