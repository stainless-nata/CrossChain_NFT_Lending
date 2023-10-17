
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./LendBorrow.sol";
import "./IBridge.sol";
import "./IInterchainGasPaymaster.sol";
import "./IMailbox.sol";

/*
    Sepolia (Config)

    mailbox = 0xCC737a94FecaeC165AbCf12dED095BB13F037685
    igp = 0x8f9C3888bFC8a5B25AED115A82eCbb788b196d2a
*/

contract Bridge {
    uint256 private GAS_LIMIT_ADDBORROWINGPOWER = 1000000;
    uint256 private GAS_LIMIT_REMOVEBORROWINGPOWER = 1000000;

    address public immutable i_owner;
    IMailbox public mailbox;
    IInterchainGasPaymaster public igp;
    LendBorrow public lendBorrow;

modifier ownerOnly {
        require(msg.sender == i_owner,"AddressIsNotOwner_Error");
         _;
    }

    constructor(address _mailbox, address _igp, address payable _lendBorrow) {
        mailbox = IMailbox(_mailbox);
        igp = IInterchainGasPaymaster(_igp);
        lendBorrow = LendBorrow(_lendBorrow);
        i_owner = msg.sender;
    }

    function updatelendBorrowAddress(address payable _lendBorrow) external ownerOnly {
    lendBorrow = LendBorrow(_lendBorrow);
    }

    function quoteFeeAddBorrowingPowerSend(
        uint32 destination
    ) external view returns (uint256) {
        return igp.quoteGasPayment(destination, GAS_LIMIT_ADDBORROWINGPOWER);
    }

    function quoteFeeRemoveBorrowingPowerSend(
        uint32 destination
    ) external view returns (uint256) {
        return igp.quoteGasPayment(destination, GAS_LIMIT_REMOVEBORROWINGPOWER);
    }

    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external {
        _origin; //to avoid compiler warning

        require(
            msg.sender == address(mailbox),
            "Bridge: Only mailbox can call this function"
        );
        require(
            _sender == bytes32(abi.encode(this)),
            "Bridge: Sender must be this contract on another chain"
        );
        (uint16 messageType, uint256 DUSD_AMOUNT, address borrowerAddress) = abi.decode(
            _message,
            (uint16, uint256, address)
        );
        if (messageType == 1) {
            // AddBorrowingPower
            lendBorrow.addBorrowingPowerByBridge(borrowerAddress, DUSD_AMOUNT );
        } else if (messageType == 2) {
            // RemoveBorrowingPower
            lendBorrow.removeBorrowingPowerByBridge(borrowerAddress);
        } 
    }

    function AddBorrowingPowerSend(
        uint32 _destination,
        uint256 _DUSD_AMOUNT,
        address _borrower,
        address _refundAddress
    ) external payable {
        bytes memory message = abi.encode(1, _DUSD_AMOUNT, _borrower);
        bytes32 messageId = mailbox.dispatch(
            _destination,
            bytes32(abi.encode(this)),
            message
        );
        igp.payForGas{value: msg.value}(
            messageId,
            _destination,
            GAS_LIMIT_ADDBORROWINGPOWER, // Gas amount
            _refundAddress
        );
    }

    function RemoveBorrowingPowerSend(
        uint32 _destination,
        uint256 _DUSD_AMOUNT,
        address _borrower,
        address _refundAddress
    ) external payable {
        bytes memory message = abi.encode(2, _DUSD_AMOUNT, _borrower);
        bytes32 messageId = mailbox.dispatch(
            _destination,
            bytes32(abi.encode(this)),
            message
        );
        igp.payForGas{value: msg.value}(
            messageId,
            _destination,
            GAS_LIMIT_REMOVEBORROWINGPOWER, // Gas amount
            _refundAddress
        );
    }
}
