// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IMessageRecipient.sol";

// Resposnsible for Interchain Communication of contracts
// All the messages will be sent and receive message between contracts

interface IBridge is IMessageRecipient {
    function quoteFeeAddBorrowingPowerSend(uint32 destination) external view returns (uint256);
    function quoteFeeRemoveBorrowingPowerSend(uint32 destination) external view returns (uint256);

    function AddBorrowingPowerSend(
        uint32 _destination,
        uint256 _DUSD_AMOUNT,
        address _to,
        address _borrowerAddress
    ) external payable;

    function RemoveBorrowingPowerSend(
        uint32 _destination,
        uint256 _DUSD_AMOUNT,
        address _to,
        address _borrowerAddress
    ) external payable;
}