// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/* Imports Here */
import {IBridge} from "./IBridge.sol";
import {IERC71} from "lib/openzeppelin-contracts/contracts/token/ERC721";
import {DUSD} from "./DUSD.sol";


contract LendBorrow {
    /*Custom Errors */
    error LendBorrow_AddressIsNotOwner_Error();
    error LendBorrow_BridgeAlreadyExists_Error();
    error LendBorrow_ContractIsNotAllowedToPullToken();
    error LendBorrow_TokenDoesNotHaveWorthInContrat();
    error LendBorrow_UserDoesNotHaveBorrowingPower();

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
    uint32[3] public constant chainIds  = [5,80001,97];

    /* State Variables */
    address public immutable i_owner;
    address payable public bridge;
    address payable public dusd_Address;
    DUSD public dusdContract;

    // Using it so that user can get back his NFT after repaying loan
    mapping(address => OriginalToken) public ownerOfOrignalTokens;

    // Using it for tracking borrowing power on multichain
    mapping(address => uint256) public borrowingPowerInUSD;

    // Using it cause at time of repying we will check if the borrower has a loan or not
    mapping(address => uint256) public addressToAssociatedLoan;

    // Using it so that in future anyone can liquidate the nft just with token id and contract address if conditions are met
    mapping(bytes32 => uint256) public bytes32OfTokenToAssociatedLoan;

    // Using it for deposit NFT check meanswe are only allowing blue chip nfts so only this listed tokens can take loan
    mapping(address=>mapping(uint256=>uint256)) public contractAddressToTokenIdToDUSDBorrowableAmount;

    /* Constructor */
    constructor(address _owner) {
        i_owner = _owner;
        dusdContract = new DUSD();
        dusd_Address = address(dusdContract);
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


    function setTokenValue(address tokenContractAddress, uint256 tokenID, uint256 DUSD_NFT_WORTH) external{
        if(msg.sender != i_owner){
            revert LendBorrow_AddressIsNotOwner_Error();
        }
        contractAddressToTokenIdToDUSDBorrowableAmount[tokenContractAddress][tokenID]= DUSD_NFT_WORTH;

    }

    // Native Chain function only
    function depositNFT(address tokenContractAddress, uint256 tokenID) external {

        /* Dev replace this function with actual security check in future */
        if(contractAddressToTokenIdToDUSDBorrowableAmount[tokenContractAddress][tokenID]==0){
            revert LendBorrow_TokenDoesNotHaveWorthInContrat();
        }

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

        /* Nft floor Price Work is remaining below uint will be populated by Floor price of nft which will be returned by Chainlink and then convert it into USD then apply all HF and stuff and i will get final DUSD_LOAN_AMOUNT*/
        uint256 DUSD_LOAN_AMOUNT = contractAddressToTokenIdToDUSDBorrowableAmount[tokenContractAddress][tokenID];

        // Update the borrowing power on native chain
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
                    msg.sender, // msg.sender can get this much DUSD
                    msg.sender // Refund Address
                )
            }
        }
    }

    // Doing For Native Chain
    function withDrawTokens() external {
        // Check if the Borrower has borrowing power or not
        if(borrowingPowerInUSD[msg.sender]==0){
            revert LendBorrow_UserDoesNotHaveBorrowingPower();
        }

        // Get the borowing power and mint usd on that borrowers address
        uint256 loanUSD = borrowingPowerInUSD[msg.sender];
        dusdContract.mint(msg.sender,loanUSD);

        //Reset the borrowing power
        borrowingPowerInUSD[msg.sender]=0;

        // Associate Loan with borrowers address
        addressToAssociatedLoan[msg.sender]=loanUSD;

        // Check which token he putted as collateral and grab tokenAddress and Token Id from it
        OriginalToken memory token = ownerOfOrignalTokens[msg.sender];
        address tokenContractAddress = token.tokenAddress;
        uint256 token_id = token.tokenId;

        // Then take the bytes32 of abi.encode(token_id,tokenContractAddress) and store associated loan to NFT.
        bytes32OfTokenToAssociatedLoan[bytes32(abi.enocde(token_id,tokenContractAddress))] = loanUSD;

        // Removing borrowing power on all chain
        for (uint i = 0; i < chainIds.length; i++){
            // Except this chain execute call for all two remaining chains
            if(block.chainid != chainIds[i]){
                uint32 chainId = chainIds[i];
                uint256 fee = IBridge(bridge).quoteFeeAddBorrowingPowerSend(chainId);
                IBridge(bridge).RemoveBorrowingPowerSend{value:fee}(
                    chainId,
                    loanUSD,
                    msg.sender, // msg.sender can get this much DUSD
                    msg.sender // Refund Address
                );
            }
        }
    }

    function withDrawTokensByBridge() external{}
    function addBorrowingPowerByBridge() external{}
    function removeBorrowingPowerByBridge() external{}
    function repayLoan() external{}
    function liquidateNFTByTransferingTheOwnerShipToDaoContract() internal{}
    function tryToLiquidateNFT() external{}

}
