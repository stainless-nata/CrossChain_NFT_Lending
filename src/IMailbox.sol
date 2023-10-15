// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IMailbox {

    /*
    Hyperlane can only deliver messages to smart contracts that implement the IMessageRecipient interface. */  

    /*
     * @notice Dispatches a message to the destination domain & recipient.
     * @param _destinationDomain Domain of destination chain
     * @param _recipientAddress Address of recipient on destination chain as bytes32
     * @param _body Raw bytes content of message body
     * @return The message ID inserted into the Mailbox's merkle tree
     */

    /* Use address to bytes32 to pass value 
    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
     */

    /* If the function is being carried out by Relayers then you have to pat gas fees on main chain 
    
    Have to use interchain pay master API
    */

    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody
    ) external returns (bytes32);

    /*
    Relayers are responsible for ensuring messages are delivered to their recipients. Relayers are a permissionless but integral part of the Hyperlane protocol. Anyone can run a relayer. */

    /*
    @dev this function will be called by relayers
    */
    function process(
        bytes calldata _metadata,
        bytes calldata _message
    ) external;
}
