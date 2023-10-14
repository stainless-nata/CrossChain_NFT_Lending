// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IMessageRecipient.sol";

// Resposnsible for Interchain Communication of contracts
// All the messages will be sent and receive message between contracts

interface IBridge is IMessageRecipient {
    function quoteFeeTransfer(uint32 destination) external view returns (uint256);
    function quoteFeeMint(uint32 destination) external view returns (uint256);
    function quoteFeeBurn(uint32 destination) external view returns (uint256);

    function transfer(
        uint32 _destination,
        uint256 _tokenId,
        address _to,
        address _refundAddress
    ) external payable;

    function mint(
        uint32 _destination,
        uint256 _tokenId,
        address _to,
        address _refundAddress
    ) external payable;

    function burn(
        uint32 _destination,
        uint256 _tokenId,
        address _refundAddress
    ) external payable;
}