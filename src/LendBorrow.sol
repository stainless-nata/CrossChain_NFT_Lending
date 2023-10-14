// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* Imports Here */
import {IBridge} from "./IBridge.sol";
import {IERC71} from "lib/openzeppelin-contracts/contracts/token/ERC721";
import {IDUSD} from "./IDUSD.sol";

contract LendBorrow {
    /*Custom Errors */
    error LendBorrow_AddressIsNotOwner_Error();
    error LendBorrow_BridgeAlreadyExists_Error();
    error LendBorrow_ContractIsNotAllowedToPullToken();

    /* Type Declarations */
    struct OriginalToken {
        address tokenAddress;
        uint256 tokenId;
    }

    /*
    0 => Goerli
    80001 => Mumbai 
    97 => BSC Testnet
    */
    uint32[3] priavte constant chainIds  = [5,80001,97];

    /* State Variables */
    address private immutable i_owner;
    address payable private bridge;

    mapping(address => OriginalToken) public ownerOfOrignalTokens;
    mapping(address => uint256) public borrowingPowerInUSD;
    mapping(address => uint256) public addressToAssociatedLoan;
    mapping(bytes32 => uint256) public bytes32OfToeknToAssociatedLoan;

    /* Constructor */
    constructor(address _owner) {
        i_owner = _owner;
    }

    function setBridge(address payable _bridge) external {
        if (msg.sender != i_owner) {
            revert LendBorrow_AddressIsNotOwner_Error();
        }
        if (bridge != address(0)) {
            revert LendBorrow_BridgeAlreadyExists_Error();
        }
        bridge = _bridge;
    }

    function depositNFT(address tokenContractAddress, uint256 tokenID) external {
        // Check if the contract is allowed to pull NFT
        if (
            IERC721(tokenContractAddress).getApproved(tokenID) != address(this)
        ) {
            revert LendBorrow_ContractIsNotAllowedToPullToken();
        }

        // Transfer NFT ownership to this contract
        IERC721(tokenContractAddress).transferFrom(
            msg.sender,
            address(this),
            tokenID
        );

        // Now store the borrowers details
        ownerOfOrignalTokens[msg.sender] = OriginalToken(
            tokenContractAddress,
            tokenID
        );

        /* Nft floor Price Work is remaining below uint will be populated by 
        Floor price of nft which will be returned by Chainlink and then convert it into USD then apply all HF and stuff and i will get final DUSD_LOAN_AMOUNT*/
        uint256 DUSD_LOAN_AMOUNT = 100;

        // Update the borrowinf power on native chain
        borrowingPowerInUSD[msg.sender] = DUSD_LOAN_AMOUNT;

        // Giving borrowing power on all chain
        for (uint i = 0; i < chainIds.length; i++){
            // Except this chain execute call for all two remaining chains
            if(block.chainid != chainIds[i]){
                uint32 chainId = chainIds[i];
                uint256 fee = IBridge(bridge).quoteFeeAddBorrowingPowerSend(chainId);
                IBridge(bridge).AddBorrowingPowerSend{value:fee}(
                    chainId,
                    DUSD_LOAN_AMOUNT,
                    msg.sender, // msg.sender should get the DUSD
                    msg.sender // Refund Address
                )
            }
        }
    }

    function withDrawTokens(){
        
    }

}
