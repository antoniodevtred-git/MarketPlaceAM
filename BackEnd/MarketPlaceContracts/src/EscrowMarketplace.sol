// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract EscrowMarketplace is Ownable, ReentrancyGuard {
    struct Item {
        uint256 id;
        address payable seller;
        uint256 usdPrice;
        bool exists;
        bool sold;
    }

    struct Escrow {
        address payable buyer;
        uint256 amount;
        bool active;
    }

    mapping(uint256 => Item) public items;
    mapping(uint256 => Escrow) public escrows;

    IERC20 public immutable paymentToken;

    event ItemListed(uint256 indexed itemId_, address indexed seller_, uint256 usdPrice_);
    event PurchaseStarted(uint256 indexed itemId_, address indexed buyer_, uint256 amount_);
    event PurchaseConfirmed(uint256 indexed itemId_, address indexed buyer_, address indexed seller_, uint256 amount_);
    event PurchaseCancelled(uint256 indexed itemId_, address indexed buyer_, uint256 amount_);

    constructor(address owner_, address paymentToken_) Ownable(owner_) {
        require(paymentToken_ != address(0), "20");
        paymentToken = IERC20(paymentToken_);
    }

    function listItem(uint256 itemId_, address payable seller_, uint256 usdPrice_) external onlyOwner {
        require(usdPrice_ > 0, "01");
        require(!items[itemId_].exists, "02");
        require(seller_ != address(0), "03");

        items[itemId_] = Item({
            id: itemId_,
            seller: seller_,
            usdPrice: usdPrice_,
            exists: true,
            sold: false
        });

        emit ItemListed(itemId_, seller_, usdPrice_);
    }

    function startPurchase(uint256 itemId_, uint256 requiredEth_) external payable nonReentrant {
        Item storage item = items[itemId_];

        require(item.exists, "04");
        require(!item.sold, "05");
        require(!escrows[itemId_].active, "10");
        require(msg.value >= requiredEth_, "11");

        escrows[itemId_] = Escrow({
            buyer: payable(msg.sender),
            amount: msg.value,
            active: true
        });

        emit PurchaseStarted(itemId_, msg.sender, msg.value);
    }

    function confirmPurchase(uint256 itemId_) external nonReentrant {
        Item storage item = items[itemId_];
        Escrow storage esc = escrows[itemId_];

        require(item.exists, "04");
        require(esc.active, "06");
        require(esc.buyer == msg.sender, "07");
        require(!item.sold, "05");

        uint256 amount_ = esc.amount;
        address payable seller_ = item.seller;

        item.sold = true;
        esc.active = false;
        esc.amount = 0;

        (bool sent_, ) = seller_.call{ value: amount_ }("");
        require(sent_, "08");

        emit PurchaseConfirmed(itemId_, msg.sender, seller_, amount_);
    }

    function cancelPurchase(uint256 itemId_) external nonReentrant {
        Item storage item = items[itemId_];
        Escrow storage esc = escrows[itemId_];

        require(item.exists, "04");
        require(esc.active, "06");
        require(esc.buyer == msg.sender, "07");
        require(!item.sold, "05");

        uint256 amount_ = esc.amount;

        esc.active = false;
        esc.amount = 0;

        (bool sent_, ) = esc.buyer.call{ value: amount_ }("");
        require(sent_, "09");

        emit PurchaseCancelled(itemId_, msg.sender, amount_);
    }

    function buyDirect(uint256 itemId_, uint256 requiredEth_) external payable nonReentrant {
        Item storage item = items[itemId_];

        require(item.exists, "04");
        require(!item.sold, "05");
        require(msg.value >= requiredEth_, "11");

        item.sold = true;

        (bool sent_, ) = item.seller.call{ value: msg.value }("");
        require(sent_, "08");

        emit PurchaseConfirmed(itemId_, msg.sender, item.seller, msg.value);
    }

    function buyDirectWithToken(uint256 itemId_, uint256 tokenAmount_) external nonReentrant {
        Item storage item = items[itemId_];

        require(item.exists, "04");
        require(!item.sold, "05");
        require(tokenAmount_ > 0, "15");

        item.sold = true;

        bool ok_ = paymentToken.transferFrom(msg.sender, item.seller, tokenAmount_);
        require(ok_, "15");

        emit PurchaseConfirmed(itemId_, msg.sender, item.seller, tokenAmount_);
    }

    function getItem(uint256 itemId_) external view returns (Item memory) {
        return items[itemId_];
    }

    function getEscrow(uint256 itemId_) external view returns (Escrow memory) {
        return escrows[itemId_];
    }

    function _forceSetSold(uint256 itemId_) external onlyOwner {
        items[itemId_].sold = true;
    }
}
