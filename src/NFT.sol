// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleNFT is ERC721Enumerable, Ownable {
    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}

    function mint(address to) public onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _mint(to, tokenId);
    }
}
