// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./ERC721Multichain.sol";
import "./IBridge.sol";
import "./IInterchainGasPaymaster.sol";
import "./IMailbox.sol";

contract Bridge {
    uint256 private GAS_LIMIT_TRANSFER = 1000000;
    uint256 private GAS_LIMIT_MINT = 1000000;
    uint256 private GAS_LIMIT_BURN = 1000000;

    IMailbox public mailbox;
    IInterchainGasPaymaster public igp;
    ERC721Multichain public erc721;

    constructor(address _mailbox, address _igp, address _erc721) {
        mailbox = IMailbox(_mailbox);
        igp = IInterchainGasPaymaster(_igp);
        erc721 = ERC721Multichain(_erc721);
    }

    function quoteFeeTransfer(
        uint32 destination
    ) external view returns (uint256) {
        return igp.quoteGasPayment(destination, GAS_LIMIT_TRANSFER);
    }

    function quoteFeeMint(uint32 destination) external view returns (uint256) {
        return igp.quoteGasPayment(destination, GAS_LIMIT_MINT);
    }

    function quoteFeeBurn(uint32 destination) external view returns (uint256) {
        return igp.quoteGasPayment(destination, GAS_LIMIT_BURN);
    }

    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external {
        require(
            msg.sender == address(mailbox),
            "Bridge: Only mailbox can call this function"
        );
        require(
            _sender == bytes32(abi.encode(this)),
            "Bridge: Sender must be this contract on another chain"
        );
        // Message is encoded as: <1 - transfer><tokenId><recipient>
        // <2 - mint><tokenId><recepient>
        (uint16 messageType, uint256 tokenId, address recipient) = abi.decode(
            _message,
            (uint16, uint256, address)
        );

        if (messageType == 1) {
            // Transfer
            erc721.transferByBridge(recipient, tokenId, _origin);
        } else if (messageType == 2) {
            // Mint
            erc721.mintByBridge(recipient, tokenId, _origin);
        } else if (messageType == 3) {
            // Token has been burned on another chain
            erc721.burnByBridge(tokenId, _origin);
        }
    }

    function transfer(
        uint32 _destination,
        uint256 _tokenId,
        address _to,
        address _refundAddress
    ) external payable {
        require(
            erc721.ownerOf(_tokenId) == _to,
            "Token must be transferred on this chain before performing external transfer"
        );
        // Message is encoded as: <1 - transfer><tokenId><recipient>
        bytes memory message = abi.encode(1, _tokenId, _to);
        bytes32 messageId = mailbox.dispatch(
            _destination,
            bytes32(abi.encode(this)),
            message
        );
        igp.payForGas{value: msg.value}(
            messageId,
            _destination,
            GAS_LIMIT_TRANSFER, // Gas amount
            _refundAddress
        );
    }

    function mint(
        uint32 _destination,
        uint256 _tokenId,
        address _to,
        address _refundAddress
    ) external payable {
        // Message is encoded as: <2 - mint><tokenId><recepient>
        bytes memory message = abi.encode(2, _tokenId, _to);
        bytes32 messageId = mailbox.dispatch(
            _destination,
            bytes32(abi.encode(this)),
            message
        );
        igp.payForGas{value: msg.value}(
            messageId,
            _destination,
            GAS_LIMIT_MINT, // Gas amount
            _refundAddress
        );
    }

    function burn(
        uint32 _destination,
        uint256 _tokenId,
        address _refundAddress
    ) external payable {
        // Message is encoded as: <3 - burn><tokenId><empty>
        bytes memory message = abi.encode(3, _tokenId, address(0));
        bytes32 messageId = mailbox.dispatch(
            _destination,
            bytes32(abi.encode(this)),
            message
        );
        igp.payForGas{value: msg.value}(
            messageId,
            _destination,
            GAS_LIMIT_BURN, // Gas amount
            _refundAddress
        );
    }
}