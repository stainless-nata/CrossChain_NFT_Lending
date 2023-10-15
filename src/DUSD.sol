// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DUSD is ERC20 {
    address public owner; // The owner of the contract

    constructor() ERC20("Decentralized USD", "DUSD") {
        owner = msg.sender; // Set the contract deployer as the owner
    }

    // Mint DUSD tokens (used when NFTs are deposited as collateral)
    function mint(address account, uint256 amount) external {
        require(msg.sender == owner, "Only the contract owner can mint DUSD");
        _mint(account, amount);
    }

    // Burn DUSD tokens (used when repaying loans)
    function burn(address account, uint256 amount) external {
        require(msg.sender == owner, "Only the contract owner can burn DUSD");
        _burn(account, amount);
    }

    // Transfer DUSD tokens to another address
    function transferDUSD(address to, uint256 amount) external {
        _transfer(msg.sender, to, amount);
    }
}