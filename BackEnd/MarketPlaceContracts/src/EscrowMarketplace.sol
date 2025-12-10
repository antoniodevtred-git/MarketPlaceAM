// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract EscrowMarketplace is Ownable, ReentrancyGuard {

    struct Item {
        uint256 id;
        address payable seller;
        uint256 usdPrice;  // Precio FIJO en USD
        bool exists;
        bool sold;
    }

    struct Escrow {
        address payable buyer;
        uint256 amount; // ETH depositado
        bool active;
    }

    // itemId => Item
    mapping(uint256 => Item) public items;

    // itemId => Escrow
    mapping(uint256 => Escrow) public escrows;

    event ItemListed(uint256 indexed itemId, address indexed seller, uint256 usdPrice);
    event PurchaseStarted(uint256 indexed itemId, address indexed buyer, uint256 amount);
    event PurchaseConfirmed(uint256 indexed itemId, address indexed buyer, address indexed seller, uint256 amount);
    event PurchaseCancelled(uint256 indexed itemId, address indexed buyer, uint256 amount);

    constructor(address owner_) Ownable(owner_) {}

    // -----------------------------------
    // ADMIN / SELLER: LISTAR ITEMS
    // -----------------------------------

    function listItem(uint256 itemId, address payable seller, uint256 usdPrice)
        external 
        onlyOwner 
    {
        require(usdPrice > 0, "01");
        require(!items[itemId].exists, "02");
        require(seller != address(0), "03");

        items[itemId] = Item({
            id: itemId,
            seller: seller,
            usdPrice: usdPrice,
            exists: true,
            sold: false
        });

        emit ItemListed(itemId, seller, usdPrice);
    }

    // -----------------------------------
    // BUYER: INICIAR COMPRA (ESCROW)
    // -----------------------------------

    function startPurchase(uint256 itemId, uint256 requiredEth)
        external 
        payable 
        nonReentrant 
    {
        Item storage item = items[itemId];

        require(item.exists, "04");
        require(!item.sold, "05");
        require(!escrows[itemId].active, "10");

        // Pago dinámico basado en USD → ETH
        require(msg.value >= requiredEth, "11");

        escrows[itemId] = Escrow({
            buyer: payable(msg.sender),
            amount: msg.value,
            active: true
        });

        emit PurchaseStarted(itemId, msg.sender, msg.value);
    }

    // -----------------------------------
    // BUYER: CONFIRMAR RECEPCION
    // -----------------------------------

    function confirmPurchase(uint256 itemId) external nonReentrant {
        Item storage item = items[itemId];
        Escrow storage esc = escrows[itemId];

        require(item.exists, "04");
        require(esc.active, "06");
        require(esc.buyer == msg.sender, "07");
        require(!item.sold, "05");

        uint256 amount = esc.amount;
        address payable seller = item.seller;

        // UPDATE STATE
        item.sold = true;
        esc.active = false;
        esc.amount = 0;

        // TRANSFER FUNDS
        (bool sent, ) = seller.call{value: amount}("");
        require(sent, "08");
        emit PurchaseConfirmed(itemId, msg.sender, seller, amount);
    }

    // -----------------------------------
    // BUYER: CANCELAR COMPRA
    // -----------------------------------

    function cancelPurchase(uint256 itemId) external nonReentrant {
        Item storage item = items[itemId];
        Escrow storage esc = escrows[itemId];

        require(item.exists, "04");
        require(esc.active, "06");
        require(esc.buyer == msg.sender, "07");
        require(!item.sold, "05");

        uint256 amount = esc.amount;

        // UPDATE STATE
        esc.active = false;
        esc.amount = 0;

        // REFUND
        (bool sent, ) = esc.buyer.call{value: amount}("");
        require(sent, "09");
        emit PurchaseCancelled(itemId, msg.sender, amount);
    }

    // -----------------------------------
    // VIEW FUNCTIONS
    // -----------------------------------

    function getItem(uint256 itemId) external view returns (Item memory) {
        return items[itemId];
    }

    function getEscrow(uint256 itemId) external view returns (Escrow memory) {
        return escrows[itemId];
    }

    
    function _forceSetSold(uint256 itemId) external { //  -----> ONLY FOR TESTING — DO NOT DEPLOY IN PRODUCTION
        items[itemId].sold = true;
    }
}
