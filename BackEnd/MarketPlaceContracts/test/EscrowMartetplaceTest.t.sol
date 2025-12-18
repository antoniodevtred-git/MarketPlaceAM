// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/EscrowMarketplace.sol";
import "../src/MarketplaceAsset.sol";
import "../src/MarketToken.sol";

contract EscrowMarketplaceTest is Test {
    EscrowMarketplace marketplace;
    MarketToken paymentToken;
    MarketplaceAsset tokenizerNFT;

    address owner  = address(1);
    address seller = address(2);
    address buyer  = address(3);
    address random = address(4);

    uint256 itemId   = 1;
    uint256 usdPrice = 2000 * 1e8;
    uint256 ethPrice = 1 ether;
    uint256 tokenId;

    // ------------------------------------------------------------
    // SETUP
    // ------------------------------------------------------------

    function setUp() public {
        vm.deal(buyer, 10 ether);
        vm.deal(seller, 10 ether);
        vm.deal(random, 10 ether);

        vm.prank(owner);
        paymentToken = new MarketToken("Market Token", "MKT", owner);

        vm.prank(owner);
        tokenizerNFT = new MarketplaceAsset(
            "MarketplaceAsset",
            "ASSET",
            owner
        );

        vm.prank(owner);
        marketplace = new EscrowMarketplace(
            owner,
            address(paymentToken),
            address(tokenizerNFT)
        );
    }

    // ------------------------------------------------------------
    // HELPERS
    // ------------------------------------------------------------

    function createItem() internal {
        vm.prank(owner);
        marketplace.listItem(itemId, payable(seller), usdPrice);
    }

    function createItemAndLinkNFT() internal {
        vm.prank(owner);
        tokenId = tokenizerNFT.mintAsset(
            address(marketplace),
            MarketplaceAsset.AssetType.REAL_ESTATE,
            "ipfs://asset"
        );

        vm.prank(owner);
        marketplace.listItemWithNFT(
            itemId,
            payable(seller),
            usdPrice,
            tokenId
        );
    }

    // ------------------------------------------------------------
    // LIST ITEM
    // ------------------------------------------------------------

    function testListItemWorks() public {
        createItem();
        EscrowMarketplace.Item memory item = marketplace.getItem(itemId);

        assertEq(item.seller, seller);
        assertEq(item.usdPrice, usdPrice);
        assertTrue(item.exists);
        assertFalse(item.sold);
    }

    function testListItemRevertsIfZeroPrice() public {
        vm.prank(owner);
        vm.expectRevert(bytes("01"));
        marketplace.listItem(itemId, payable(seller), 0);
    }

    // ------------------------------------------------------------
    // ESCROW ETH FLOW
    // ------------------------------------------------------------

    function testStartPurchaseWorks() public {
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        EscrowMarketplace.Escrow memory esc = marketplace.getEscrow(itemId);
        assertEq(esc.buyer, buyer);
        assertEq(esc.amount, ethPrice);
        assertTrue(esc.active);
    }

    function testConfirmPurchaseTransfersETH() public {
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        uint256 sellerBefore = seller.balance;

        vm.prank(buyer);
        marketplace.confirmPurchase(itemId);

        assertEq(seller.balance, sellerBefore + ethPrice);
    }

    function testCancelPurchaseRefundsBuyer() public {
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        uint256 before = buyer.balance;

        vm.prank(buyer);
        marketplace.cancelPurchase(itemId);

        assertGt(buyer.balance, before - 0.01 ether);
    }

    // ------------------------------------------------------------
    // DIRECT BUY (ETH)
    // ------------------------------------------------------------

    function testBuyDirectWorks() public {
        createItem();

        uint256 sellerBefore = seller.balance;

        vm.prank(buyer);
        marketplace.buyDirect{value: ethPrice}(itemId, ethPrice);

        assertEq(seller.balance, sellerBefore + ethPrice);
        assertTrue(marketplace.getItem(itemId).sold);
    }

    // ------------------------------------------------------------
    // DIRECT BUY (ERC20)
    // ------------------------------------------------------------

    function testBuyDirectWithTokenWorks() public {
        createItem();

        vm.prank(owner);
        paymentToken.mint(buyer, 100 ether);

        uint256 sellerBefore = paymentToken.balanceOf(seller);

        vm.startPrank(buyer);
        paymentToken.approve(address(marketplace), 100 ether);
        marketplace.buyDirectWithToken(itemId, 100 ether);
        vm.stopPrank();

        assertEq(
            paymentToken.balanceOf(seller),
            sellerBefore + 100 ether
        );
    }

    // ------------------------------------------------------------
    // NFT INTEGRATION
    // ------------------------------------------------------------

    function testBuyDirectWithTokenTransfersNFT() public {
        createItemAndLinkNFT();

        vm.prank(owner);
        paymentToken.mint(buyer, 100 ether);

        vm.startPrank(buyer);
        paymentToken.approve(address(marketplace), 100 ether);
        marketplace.buyDirectWithToken(itemId, 100 ether);
        vm.stopPrank();

        assertEq(tokenizerNFT.ownerOf(tokenId), buyer);
    }

    function testConfirmPurchaseTransfersNFT() public {
        createItemAndLinkNFT();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        vm.prank(buyer);
        marketplace.confirmPurchase(itemId);

        assertEq(tokenizerNFT.ownerOf(tokenId), buyer);
    }
}
