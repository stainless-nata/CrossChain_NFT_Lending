// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IMessageRecipient {

    /* Only Mailbox contract should be able to call this function for security reasons */
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external;
}