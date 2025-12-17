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

    address owner = address(1);
    address seller = address(2);
    address buyer  = address(3);

    uint256 itemId = 1;
    uint256 usdPrice = 2000 * 1e8;
    uint256 tokenId;


   function setUp() public {
    vm.deal(buyer, 10 ether);
    vm.deal(seller, 10 ether);

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

    // ------------------------------------------------------------
    // LIST ITEM
    // ------------------------------------------------------------

    function testListItemWorks() public { // PASS
        vm.prank(owner);
        marketplace.listItem(itemId, payable(seller), usdPrice);

        EscrowMarketplace.Item memory item = marketplace.getItem(itemId);

        assertEq(item.id, itemId);
        assertEq(item.usdPrice, usdPrice);
        assertEq(item.seller, seller);
        assertEq(item.exists, true);
        assertEq(item.sold, false);
    }

    function testListItemRevertsIfPriceZero() public { // PASS
        vm.prank(owner);
        vm.expectRevert(bytes("01"));
        marketplace.listItem(itemId, payable(seller), 0);
    }

    function testListItemRevertsIfItemExists() public { // PASS
        vm.startPrank(owner);
        marketplace.listItem(itemId, payable(seller), usdPrice);

        vm.expectRevert(bytes("02"));
        marketplace.listItem(itemId, payable(seller), usdPrice);
        vm.stopPrank();
    }

    function testListItemRevertsInvalidSeller() public { // PASS
        vm.prank(owner);
        vm.expectRevert(bytes("03"));
        marketplace.listItem(itemId, payable(address(0)), usdPrice);
    }

    function testOnlyOwnerCanListItem() public { // PASS
        vm.prank(buyer);
        vm.expectRevert();
        marketplace.listItem(itemId, payable(seller), usdPrice);
    }

    // ------------------------------------------------------------
    // START PURCHASE
    // ------------------------------------------------------------

    function testStartPurchaseWorks() public {  
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        EscrowMarketplace.Escrow memory esc = marketplace.getEscrow(itemId);

        assertEq(esc.buyer, buyer);
        assertEq(esc.amount, ethPrice);
        assertEq(esc.active, true);
    }

    function testStartPurchaseRevertsInvalidItem() public { 
        vm.prank(buyer);
        vm.expectRevert(bytes("04"));
        marketplace.startPurchase{value: ethPrice}(999, ethPrice);
    }

    function testStartPurchaseRevertsIfAlreadySold() public {
        createItem();

        
        vm.prank(owner);
        marketplace._forceSetSold(itemId);

        uint256 requiredEth = 1 ether;

        vm.prank(buyer);
        vm.expectRevert(bytes("05"));
        marketplace.startPurchase{value: requiredEth}(itemId, requiredEth);
    }


    function testStartPurchaseRevertsWrongAmount() public { // PASS
        createItem();

        vm.prank(buyer);
        vm.expectRevert(bytes("11"));
        marketplace.startPurchase{value: ethPrice - 1}(itemId, ethPrice);
    }

    function testStartPurchaseRevertsIfEscrowActive() public { // PASS
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        vm.prank(random);
        vm.expectRevert(bytes("10"));
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);
    }

    // ------------------------------------------------------------
    // CONFIRM PURCHASE
    // ------------------------------------------------------------

    function testConfirmPurchaseWorks() public { // PASS
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        uint256 sellerBefore = seller.balance;

        vm.prank(buyer);
        marketplace.confirmPurchase(itemId);

        uint256 sellerAfter = seller.balance;

        assertEq(sellerAfter, sellerBefore + ethPrice);

        EscrowMarketplace.Item memory item = marketplace.getItem(itemId);
        assertEq(item.sold, true);

        EscrowMarketplace.Escrow memory esc = marketplace.getEscrow(itemId);
        assertEq(esc.active, false);
        assertEq(esc.amount, 0);
    }

    function testConfirmPurchaseRevertsInvalidItem() public { // PASS
        vm.prank(buyer);
        vm.expectRevert(bytes("04"));
        marketplace.confirmPurchase(777);
    }

    function testConfirmPurchaseRevertsIfNoEscrow() public { // PASS
        createItem();

        vm.prank(buyer);
        vm.expectRevert(bytes("06"));
        marketplace.confirmPurchase(itemId);
    }

    function testConfirmPurchaseRevertsIfNotBuyer() public { // PASS
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        vm.prank(random);
        vm.expectRevert(bytes("07"));
        marketplace.confirmPurchase(itemId);
    }

    // ------------------------------------------------------------
    // CANCEL PURCHASE
    // ------------------------------------------------------------

    function testCancelPurchaseWorks() public { // PASS 
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        uint256 before = buyer.balance;

        vm.prank(buyer);
        marketplace.cancelPurchase(itemId);

        uint256 afterBal = buyer.balance;

        assertGt(afterBal, before - 0.01 ether); 
    }

    function testCancelPurchaseRevertsIfNoEscrow() public { // PASS
        createItem();

        vm.prank(buyer);
        vm.expectRevert(bytes("06"));
        marketplace.cancelPurchase(itemId);
    }

    function testCancelPurchaseRevertsIfNotBuyer() public { 
        createItem();

        vm.prank(buyer);
        marketplace.startPurchase{value: ethPrice}(itemId, ethPrice);

        vm.prank(random);
        vm.expectRevert(bytes("07"));
        marketplace.cancelPurchase(itemId);
    }

    function testBuyDirectWorks() public {
        createItem();

        uint256 sellerBefore = seller.balance;

        vm.prank(buyer);
        marketplace.buyDirect{value: ethPrice}(itemId, ethPrice);

        assertEq(seller.balance, sellerBefore + ethPrice);

        EscrowMarketplace.Item memory item = marketplace.getItem(itemId);
        assertTrue(item.sold);
    }

    function testBuyDirectRevertsIfInvalidItem() public {
        vm.prank(buyer);
        vm.expectRevert(bytes("04"));
        marketplace.buyDirect{value: ethPrice}(999, ethPrice);
    }

    function testBuyDirectRevertsIfAlreadySold() public {
        createItem();

        vm.prank(buyer);
        marketplace.buyDirect{value: ethPrice}(itemId, ethPrice);

        vm.prank(random);
        vm.expectRevert(bytes("05"));
        marketplace.buyDirect{value: ethPrice}(itemId, ethPrice);
    }

    function testBuyDirectRevertsIfWrongAmount() public {
        createItem();

        vm.prank(buyer);
        vm.expectRevert(bytes("11"));
        marketplace.buyDirect{value: ethPrice - 1}(itemId, ethPrice);
    }

    function testBuyDirectWithTokenWorks() public {
        createItem();

        uint256 amount = 500 ether;

        // Mint tokens to buyer (owner is the token owner)
        vm.prank(owner);
        token.mint(buyer, amount);

        uint256 sellerBefore = token.balanceOf(seller);

        // Approve + buy
        vm.startPrank(buyer);
        token.approve(address(marketplace), amount);
        marketplace.buyDirectWithToken(itemId, amount);
        vm.stopPrank();

        // Seller received tokens
        assertEq(token.balanceOf(seller), sellerBefore + amount);

        // Item sold
        EscrowMarketplace.Item memory item = marketplace.getItem(itemId);
        assertTrue(item.sold);
    }

    function testBuyDirectWithTokenRevertsIfInvalidItem() public {
        vm.prank(buyer);
        vm.expectRevert(bytes("04"));
        marketplace.buyDirectWithToken(999, 1 ether);
    }

    function testBuyDirectWithTokenRevertsIfAlreadySold() public {
        createItem();

        // Mark as sold (owner-only helper)
        vm.prank(owner);
        marketplace._forceSetSold(itemId);

        vm.prank(buyer);
        vm.expectRevert(bytes("05"));
        marketplace.buyDirectWithToken(itemId, 1 ether);
    }

    function testBuyDirectWithTokenRevertsIfZeroAmount() public {
        createItem();

        vm.prank(buyer);
        vm.expectRevert(bytes("13"));
        marketplace.buyDirectWithToken(itemId, 0);
    }

    function testBuyDirectWithTokenRevertsIfNoApprovalOrBalance() public {
        createItem();

        uint256 amount = 100 ether;

        // buyer has 0 tokens and no approval -> transferFrom should fail => "15"
        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyDirectWithToken(itemId, amount);
    }

    function testBuyDirectWithTokenRevertsIfNotEnoughAllowance() public {
        createItem();

        uint256 amount = 100 ether;

        vm.prank(owner);
        token.mint(buyer, amount);

        vm.startPrank(buyer);
        token.approve(address(marketplace), amount - 1);
        vm.expectRevert();
        marketplace.buyDirectWithToken(itemId, amount);
        vm.stopPrank();
    }
    function testBuyDirectWithTokenTransfersNFT() public {
        createItemAndLinkNFT();

        vm.prank(owner);
        token.mint(buyer, 100 ether);

        vm.startPrank(buyer);
        token.approve(address(marketplace), 100 ether);
        marketplace.buyDirectWithToken(itemId, 100 ether);
        vm.stopPrank();

        assertEq(tokenizerNFT.ownerOf(tokenId), buyer);
    }
    

}
