// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/TokenizerNFT.sol";

contract TokenizerNFTTest is Test {

    TokenizerNFT tokenizer;

    address owner = address(1);
    address user  = address(2);

    uint256 itemId = 1;

    function setUp() public {
        tokenizer = new TokenizerNFT("TokenizerNFT", "TNFT", owner);
    }

    function testTokenizeWorks() public {
        vm.prank(owner);
        uint256 tokenId = tokenizer.tokenize(user, itemId, "ipfs://asset");

        assertEq(tokenizer.ownerOf(tokenId), user);
        assertEq(tokenizer.tokenURI(tokenId), "ipfs://asset");
        assertEq(tokenizer.getTokenByItem(itemId), tokenId);
        assertEq(tokenizer.getItemByToken(tokenId), itemId);
    }

    function testTokenizeRevertsIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert();
        tokenizer.tokenize(user, itemId, "ipfs://asset");
    }

    function testTokenizeRevertsIfZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(bytes("12")); // INVALID_ADDRESS
        tokenizer.tokenize(address(0), itemId, "ipfs://asset");
    }

    function testTokenizeRevertsIfItemAlreadyTokenized() public {
        vm.prank(owner);
        tokenizer.tokenize(user, itemId, "ipfs://asset");

        vm.prank(owner);
        vm.expectRevert(bytes("24")); // NFT_ALREADY_EXISTS
        tokenizer.tokenize(user, itemId, "ipfs://asset2");
    }
}
