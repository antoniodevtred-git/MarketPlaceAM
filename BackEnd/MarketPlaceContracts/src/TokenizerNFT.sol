// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TokenizerNFT is ERC721URIStorage, Ownable {

    uint256 public nextTokenId = 1;

    // itemId (EscrowMarketplace) => tokenId
    mapping(uint256 => uint256) public itemToToken;

    // tokenId => itemId
    mapping(uint256 => uint256) public tokenToItem;

    event NFTTokenized(
        uint256 indexed tokenId_,
        uint256 indexed itemId_,
        address indexed owner_,
        string uri_
    );

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_
    )
        ERC721(name_, symbol_)
        Ownable(owner_)
    {}

    function tokenize(
        address to_,
        uint256 itemId_,
        string calldata uri_
    )
        external
        onlyOwner
        returns (uint256 tokenId_)
    {
        require(to_ != address(0), "12");              // INVALID_ADDRESS
        require(itemToToken[itemId_] == 0, "24");      // NFT_ALREADY_EXISTS

        tokenId_ = nextTokenId++;
        _safeMint(to_, tokenId_);
        _setTokenURI(tokenId_, uri_);

        itemToToken[itemId_] = tokenId_;
        tokenToItem[tokenId_] = itemId_;

        emit NFTTokenized(tokenId_, itemId_, to_, uri_);
    }

    function getTokenByItem(uint256 itemId_) external view returns (uint256) {
        return itemToToken[itemId_];
    }

    function getItemByToken(uint256 tokenId_) external view returns (uint256) {
        return tokenToItem[tokenId_];
    }
}
