🧱 Web3 Marketplace Backend

A complete Web3 Marketplace backend, built with Solidity and Foundry, focused on clean architecture, security, modularity, and extensive testing.

This project is part of an advanced Web3 learning journey and is fully prepared to be integrated with a frontend application.

🚀 Features
🏪 Marketplace with Escrow

Item listing managed by the owner

Direct purchase with ETH

Escrow-based purchase flow:

Start purchase

Buyer confirmation

Buyer cancellation and refund

Direct purchase with ERC20 tokens

Clear item lifecycle (exists, sold, escrow active)

Reentrancy protection on critical functions

🖼️ Asset Tokenization (NFTs)

ERC721 NFTs representing marketplace assets

NFTs linked to marketplace items

Automatic NFT transfer to the buyer after purchase

Fully integrated with ETH and ERC20 purchase flows

🪙 ERC20 Token

Custom ERC20 token (MarketToken)

Used for:

Marketplace payments

Staking

Owner-controlled minting

Input validation and standardized error codes

🔒 Staking

Fixed-amount staking per user

Only one active stake per address

Rewards paid in ETH

Configurable staking periods

Protection against:

Double staking

Early reward claims

Insufficient ETH rewards in contract

🔁 Token Swap

MarketSwap contract

Swap any ERC20 token into the MarketToken

Integration with a Uniswap V2–style router

Router fully mocked for testing

Strong validations:

Valid path

Correct output token

Amount > 0

Valid deadline

🧪 Testing & Quality

Framework: Foundry

Unit and integration tests

Mocks for:

ERC20 tokens

Uniswap V2 router

Global test coverage above 90%

Tests include:

Happy paths

Expected reverts

End-to-end flows

Run tests
forge test

Run coverage
forge coverage

🗂️ Project Structure
src/
 ├─ EscrowMarketplace.sol
 ├─ MarketplaceAsset.sol
 ├─ TokenizerNFT.sol
 ├─ MarketToken.sol
 ├─ MarketSwap.sol
 ├─ StakingMarket.sol
 └─ interfaces/

test/
 ├─ EscrowMarketplaceTest.t.sol
 ├─ MarketplaceAssetTest.t.sol
 ├─ TokenizerNFTTest.t.sol
 ├─ MarketTokenTest.t.sol
 ├─ MarketSwapTest.t.sol
 ├─ MarketStakingTest.t.sol
 └─ mocks/
     ├─ MockERC20.sol
     └─ MockV2Router02.sol

⚠️ Error Handling

All contracts use standardized numeric error codes to:

Reduce gas usage

Improve debugging

Maintain consistency across the system

Examples:

01 → PRICE_ZERO

04 → INVALID_ITEM

05 → ALREADY_SOLD

15 → TOKEN_TRANSFER_FAILED

26 → NFT_NOT_LINKED

🔐 Security

ReentrancyGuard on critical functions

Checks-Effects-Interactions pattern

Strict input validation

SafeERC20 usage where applicable

Safe and verified ETH transfers

🛠️ Tech Stack

Solidity ^0.8.24

Foundry

OpenZeppelin Contracts

Modular and decoupled architecture
