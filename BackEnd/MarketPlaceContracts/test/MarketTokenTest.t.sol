// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/MarketToken.sol";

contract MarketTokenTest is Test {

    MarketToken token;

    address owner = address(1);
    address user  = address(2);

    uint256 INITIAL_SUPPLY = 1_000_000 * 1e18;

    function setUp() public {
        vm.prank(owner);
        token = new MarketToken("Market Token", "MKT", owner);
    }

    function testInitialSupplyMintedToOwner() public {
        uint256 balance = token.balanceOf(owner);
        assertEq(balance, INITIAL_SUPPLY);
    }

    function testOwnerIsCorrect() public {
        assertEq(token.owner(), owner);
    }

    function testOwnerCanMint() public {
        vm.prank(owner);
        token.mint(user, 100 * 1e18);

        assertEq(token.balanceOf(user), 100 * 1e18);
    }

    function testMintIncreasesTotalSupply() public {
        uint256 supplyBefore = token.totalSupply();

        vm.prank(owner);
        token.mint(user, 50 * 1e18);

        uint256 supplyAfter = token.totalSupply();
        assertEq(supplyAfter, supplyBefore + 50 * 1e18);
    }

    function testMintRevertsIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert(); 
        token.mint(user, 10 * 1e18);
    }

    function testMintRevertsIfZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(bytes("12"));
        token.mint(address(0), 10 * 1e18);
    }

    function testMintRevertsIfAmountZero() public {
        vm.prank(owner);
        vm.expectRevert(bytes("13"));
        token.mint(user, 0);
    }
}
