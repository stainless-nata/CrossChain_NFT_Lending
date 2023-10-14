// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Proof NFT contract we will prvide proof nft with this contracts
interface Wrappable {
    event Wrapped(
        address indexed originalToken,
        uint256 indexed originalTokenId,
        uint256 indexed tokenId
    );
    event Unwrapped(
        address indexed originalToken,
        uint256 indexed originalTokenId,
        uint256 indexed tokenId
    );

    function wrap(address originalToken, uint256 originalTokenId) external;

    function unwrap(uint256 tokenId) external;
}