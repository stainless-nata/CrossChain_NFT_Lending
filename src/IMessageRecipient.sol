// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMessageRecipient {

    /* Only Mailboc contract should be able to call this function for security reasons */
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external;
}