// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract MarketplaceAsset is ERC721URIStorage, Ownable {

    // ------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------

    enum AssetType {
        REAL_ESTATE,
        VEHICLE,
        LUXURY
    }

    struct AssetData {
        AssetType assetType;
        bool exists;
    }

    // ------------------------------------------------------------
    // STATE
    // ------------------------------------------------------------

    uint256 public nextTokenId = 1;
    mapping(uint256 => AssetData) public assetData;

    // ------------------------------------------------------------
    // EVENTS
    // ------------------------------------------------------------

    event AssetMinted(
        uint256 indexed tokenId_,
        address indexed to_,
        AssetType assetType_,
        string uri_
    );

    // ------------------------------------------------------------
    // CONSTRUCTOR
    // ------------------------------------------------------------

    constructor(
        string memory name_,
        string memory symbol_,
        address owner_
    ) ERC721(name_, symbol_) Ownable(owner_) {}

    // ------------------------------------------------------------
    // MINT
    // ------------------------------------------------------------

    function mintAsset(
        address to_,
        AssetType assetType_,
        string calldata uri_
    ) external onlyOwner returns (uint256 tokenId_) {

        require(to_ != address(0), "12");

        tokenId_ = nextTokenId;
        nextTokenId++;

        _safeMint(to_, tokenId_);
        _setTokenURI(tokenId_, uri_);

        assetData[tokenId_] = AssetData({
            assetType: assetType_,
            exists: true
        });

        emit AssetMinted(tokenId_, to_, assetType_, uri_);
    }

    // ------------------------------------------------------------
    // VIEW
    // ------------------------------------------------------------

    function getAssetType(uint256 tokenId_)
        external
        view
        returns (AssetType)
    {
        require(assetData[tokenId_].exists, "04");
        return assetData[tokenId_].assetType;
    }
}
