POC
    1. LendBorrow.sol *3
       *Bridge Instance for Native Bridge contract 
       *chainlink NFT floor price feed => Contract Instance ***
       *public Mapping of owner address to struct{tokenID,tokenContractAddress}  (Populate only on Main Chain )
       *mapping of address to borrowing power (Will be Poluated for All chains)
       *mapping of Borrowed address to amount Loan(Amount)     (Populate only on Main Chain)
       *mapping of bytes32(nft_tokenID, TokenContract Address) to borrowed Loan amount      (Populate only on Main Chain)

       A. TakeLoan Function { 
          A1. Sub function (Give Lending power)
            - take orignal NFT ownership to contract.
            - *check floor price of NFT Chainlink function call ***
            - Use Bridge to inform all other chains the borrowing power(In terms of DUSUD) of that owner (MAILBOX) populate mapping(borrowing power) on this contract and use bridge tell other bridges to give this address borrowing power (To populate mapping on All Chains)
            - // Security check then we will store timestamp of 

          A2. Sub function (Borrow Money)
            - Check if the user has borrowing power or not 
            - If he has borrwing power then transfer equivalent amount of total DUSD to borrower address and use bool to check whether the function call was executed or not
            - if bool gets true thrash all borrowing power of user on native chain also call bridge.mailbox to tell each chain that borrower has borrwed dont give him money anymore (To populate mapping on All Chains)
            - Add mapping of Borrowed address to amount borrowed Loan(Amount) (Poulate Mapping on Main Chain)
            - Add mapping of bytes32(nft_tokenID, TokenContract Address) to borrowed Loan amount (Poulate Mapping on Main Chain)
            - Loan is done
           } 

       B. Repay Function For Native NFT (All Main chain) { 
            B1. Sub function 
                - Check mapping of Borrowed address to amount borrowed Loan Amount if he has loan then check the provided tokens and the Loan amount is same then take tokens
                - Thrash the mapping of Borrowed address to Loan amount for borrower.    (Poulate Mapping on Main Chain)
                - Also thrash the mapping of NFT ownership (Ref=> public Mapping of owner address to struct{tokenID,tokenContractAddress}). (Poulate Mapping on Main Chain)
                - Also thrash the mapping of bytes32(nft_tokenID, TokenContract Address) to borrowed Loan amount.     (Poulate Mapping on Main Chain)
                - Also give back ownership of NFT to borrower
           } 

        
        C. Liquidation Function For NFT { 
            B1. Sub function (Transfer the ownership of NFT to DAO Contract)
                - Reset the mapping of Borrowed address to Loan amount (Amount) for borrower. (Poulate Mapping on Main Chain)
                - Also thrash the mapping of bytes32(nft_tokenID, TokenContract Address) to borrowed Loan amount.     (Poulate Mapping on Main Chain)
                - Also change the mapping of NFT ownership from borrower address to DAO contract address (Ref=> public Mapping of owner address to struct{tokenID,tokenContractAddress}) (Main Chain)
                - Also give back ownership of NFT to DAO Contract
           }
         
        D. Update Loan { 
            B1. Sub function (Only this function can liquidate NFT)
                - Check the Floor price of NFT by using(Chainlink NFT floor ptice using token id,contract)
                - Take Nft token ID, and contract address of that NFT take bytes32 of it and check the mapping[bytes32]=>Loan amount
                - If the Loan amount is above Floor price udate HF. 
                - If the HF is not satified then call liquidation function
        }
         
    
    2. Bridge.sol *3 
   
        + Contract instance of Native LendingBorrower contract 
        + Quote fees setup for two functions (AddLendingPower,RemoveLendingPower) 

        Only two functions 
            A. Receieve poc (handle())
               - add Borrowing Power (MessageType = 1)
                 - function should recieve message consist of (messageType 1, DUSD Amount, Borrower Address) and then call the function which adds the borrowing power on LendBorrower.sol
               - Remove Borrwing Power (MessageType = 2)
                 - function should recieve message consist of  (messageType 2, DUSD Amount, Borrower Address) and then call the function which adds the borrowing power on LendBorrower.sol
            
            B. Send POC (mailbox.dispatch())
                - AddBorrowingPowerSend 
                    + Will be called by LendingBorrowing.sol with values + (destination Chain, messageType 1, DUSD Amount, Borrower Address)
                    + Calculate the stuff
                    + mailbox.dispatch()
                    + use IGP paymaster to pay gas
                    Use IGP master and call the

                - RemoveBorrowingPowerSend 
                    + Will be called by LendingBorrowing.sol with values + (destination Chain, messageType 2, DUSD Amount, Borrower Address)
                    + Calculate the stuff
                    + mailbox.dispatch()
                    + use IGP paymaster to pay gas
                    Use IGP master and call the


    3. DUSD.sol 3
        + Simple ERC20 contract which will be deployed by 
        LendBorrow.sol on all 3 chains
        + Only the Owner can call the mint function which will only be called at time of Giving Borrower his token
        + When paying back the user will call transfer function from the DUSD contract will transfer equivalent amount to contract

    4. DAO.sol
    // Azhar bhai will decide what to do with that NFT
