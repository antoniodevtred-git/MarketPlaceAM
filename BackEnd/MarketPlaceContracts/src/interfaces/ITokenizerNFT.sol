// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface ITokenizerNFT {
    enum AssetType {
        REAL_ESTATE,
        VEHICLE,
        LUXURY
    }

    function mintAsset(address to_, AssetType assetType_, string calldata uri_) external returns (uint256);

    function ownerOf(uint256 tokenId_) external view returns (address);

    function safeTransferFrom(address from_, address to_, uint256 tokenId_) external;
}
