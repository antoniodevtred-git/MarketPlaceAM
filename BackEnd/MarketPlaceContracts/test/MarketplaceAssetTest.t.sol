// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/MarketplaceAsset.sol";

contract MarketplaceAssetTest is Test {
    MarketplaceAsset nft;

    address owner = address(1);
    address user  = address(2);

    function setUp() public {
        nft = new MarketplaceAsset("MarketplaceAsset", "ASSET", owner);
    }

    function testMintAssetWorks() public {
        vm.prank(owner);
        uint256 tokenId = nft.mintAsset(user, MarketplaceAsset.AssetType.REAL_ESTATE, "ipfs://uri");

        assertEq(nft.ownerOf(tokenId), user);
        assertEq(nft.tokenURI(tokenId), "ipfs://uri");

        MarketplaceAsset.AssetType t = nft.getAssetType(tokenId);
        assertEq(uint256(t), uint256(MarketplaceAsset.AssetType.REAL_ESTATE));
    }

    function testMintRevertsIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert();
        nft.mintAsset(user, MarketplaceAsset.AssetType.VEHICLE, "ipfs://uri");
    }

    function testMintRevertsIfZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(bytes("12"));
        nft.mintAsset(address(0), MarketplaceAsset.AssetType.LUXURY, "ipfs://uri");
    }

}