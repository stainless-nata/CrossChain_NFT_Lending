// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts//token/ERC721/IERC721.sol";
import "@openzeppelin/contracts//token/ERC721/ERC721.sol";

contract normalNft is ERC721{
    mapping (uint256 => string) tokenURIs;
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}
     function mint(address to, uint256 tokenId, string calldata uri) public {
        _mint(to, tokenId);
        tokenURIs[tokenId] = uri;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        _requireOwned(tokenId);
        return tokenURIs[tokenId];
    }

}