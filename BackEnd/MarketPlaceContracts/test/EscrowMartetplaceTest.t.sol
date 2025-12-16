// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/EscrowMarketplace.sol";

contract EscrowMarketplaceTest is Test {

    EscrowMarketplace marketplace;

    address owner = address(1);
    address seller = address(2);
    address buyer = address(3);
    address random = address(4);

    uint256 itemId = 1;
    uint256 usdPrice = 2000 * 1e8; // 2000 USD en 8 decimales
    uint256 ethPrice = 1 ether;    // lo simula el front

    function setUp() public {
        vm.deal(buyer, 10 ether);
        vm.deal(seller, 10 ether);
        vm.deal(random, 10 ether);

        marketplace = new EscrowMarketplace(owner);
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




}
