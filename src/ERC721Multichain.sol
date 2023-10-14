// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "./Wrappable.sol";
import "./IBridge.sol";

contract ERC721Multichain is ERC721("ERC721Multichain", "MNFT"), Wrappable {
    // Authorized address bridge. Can mint & transfer any token.
    address payable public bridge;
    // ID of the token -> chain ID where the main token exists
    // Populated only when token IS NOT native to this chain
    mapping(uint256 => uint32) public mainChain;

    // ID of the token -> list of chains where the token exists
    // Populated only when token IS native to this chain
    mapping(uint256 => uint32[]) public tokenChains;

    function setBridge(address payable _bridge) external {
        require(bridge == address(0), "ERC721Multichain: Bridge already set");

        bridge = _bridge;
    }

    // Contract address of original ERC721, Asset ID in that token.
    struct OriginalToken {
        address tokenAddress;
        uint256 tokenId;
    }

    // ID of the token -> OriginalToken
    mapping(uint256 => OriginalToken) public originalTokens;

    function multichainTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable {
        super.transferFrom(from, to, tokenId);
        if (mainChain[tokenId] == 0) {
            // Token is native to this chain
            // We need to transfer it on all other chains
            for (uint256 i = 0; i < tokenChains[tokenId].length; i++) {
                uint32 chainId = tokenChains[tokenId][i];
                uint256 fee = IBridge(bridge).quoteFeeTransfer(chainId);
                IBridge(bridge).transfer{value: fee}(
                    chainId,
                    tokenId,
                    to,
                    msg.sender
                );
            }
        } else {
            // Token is not native to this chain
            // We need to transfer it on the main chain, after which it will be transferred to all other chains
            IBridge(bridge).transfer{value: msg.value}(
                mainChain[tokenId],
                tokenId,
                to,
                msg.sender
            );
        }
    }

    function bridgeToken(uint32 destination, uint256 tokenId) public payable {
        require(
            _isAuthorized(msg.sender,msg.sender, tokenId),
            "ERC721Multichain: caller is not owner nor approved"
        );
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain"
        );

        tokenChains[tokenId].push(destination);
        IBridge(bridge).mint{value: msg.value}(
            destination,
            tokenId,
            ownerOf(tokenId),
            msg.sender
        );
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain, use multichain transfer"
        );
        require(
            tokenChains[tokenId].length == 0,
            "ERC721Multichain: Token must exist only on this chain, use multichain transfer"
        );
        super.transferFrom(from, to, tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain, see URI on main chain"
        );
        require(
            originalTokens[tokenId].tokenAddress != address(0),
            "ERC721Multichain: Token is not wrapped"
        );

        return
            IERC721Metadata(originalTokens[tokenId].tokenAddress).tokenURI(
                originalTokens[tokenId].tokenId
            );
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain, use multichain transfer"
        );
        require(
            tokenChains[tokenId].length == 0,
            "ERC721Multichain: Token must exist only on this chain, use multichain transfer"
        );
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain, use multichain transfer"
        );
        require(
            tokenChains[tokenId].length == 0,
            "ERC721Multichain: Token must exist only on this chain, use multichain transfer"
        );
        super.safeTransferFrom(from, to, tokenId, data);
    }

    function transferByBridge(
        address to,
        uint256 tokenId,
        uint32 origin
    ) external {
        require(
            msg.sender == bridge,
            "ERC721Multichain: Only bridge can call this function"
        );
        if (mainChain[tokenId] == 0) {
            for (uint256 i = 0; i < tokenChains[tokenId].length; i++) {
                uint32 chainId = tokenChains[tokenId][i];
                if (tokenChains[tokenId][i] == origin) continue;
                uint256 fee = IBridge(bridge).quoteFeeTransfer(chainId);
                IBridge(bridge).transfer{value: fee}(
                    chainId,
                    tokenId,
                    to,
                    msg.sender
                );
            }
        } else {
            _transfer(ownerOf(tokenId), to, tokenId);
        }
    }

    function mintByBridge(address to, uint256 tokenId, uint32 origin) external {
        require(
            msg.sender == bridge,
            "ERC721Multichain: Only bridge can call this function"
        );
        _mint(to, tokenId);
        mainChain[tokenId] = origin;
    }

    function burnByBridge(uint256 tokenId, uint32 whereBurned) external {
        require(
            msg.sender == bridge,
            "ERC721Multichain: Only bridge can call this function"
        );
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain"
        );

        removeElement(tokenId, whereBurned);
    }

    function burn(uint256 tokenId) external payable {
        require(
            _isAuthorized(msg.sender,msg.sender, tokenId),
            "ERC721Multichain: Caller is not owner nor approved"
        );
        require(
            originalTokens[tokenId].tokenAddress == address(0),
            "ERC721Multichain: Token is wrapped"
        );
        require(
            mainChain[tokenId] != 0,
            "ERC721Multichain: Token should be unwrapped"
        );
        IBridge(bridge).burn{value: msg.value}(
            mainChain[tokenId],
            tokenId,
            msg.sender
        );

        _burn(tokenId);
    }

    function wrap(address originalToken, uint256 originalTokenId) external {
        require(
            IERC721(originalToken).getApproved(originalTokenId) ==
                address(this),
            "ERC721Multichain: Token is not approved"
        );

        IERC721(originalToken).transferFrom(
            msg.sender,
            address(this),
            originalTokenId
        );

        uint256 wrappedTokenId = uint256(
            keccak256(abi.encode(originalToken, originalTokenId))
        );
        originalTokens[wrappedTokenId] = OriginalToken(
            originalToken,
            originalTokenId
        );
        _mint(msg.sender, wrappedTokenId);

        emit Wrapped(originalToken, originalTokenId, wrappedTokenId);
    }

    function unwrap(uint256 tokenId) external {
        require(
            _isAuthorized(msg.sender,msg.sender, tokenId),
            "ERC721Multichain: Caller is not owner nor approved"
        );
        require(
            originalTokens[tokenId].tokenAddress != address(0),
            "ERC721Multichain: Token is not wrapped"
        );
        require(
            mainChain[tokenId] == 0,
            "ERC721Multichain: Token is not on main chain"
        );
        require(
            tokenChains[tokenId].length == 0,
            "ERC721Multichain: Token must exist only on this chain"
        );
        _burn(tokenId);

        OriginalToken memory originalToken = originalTokens[tokenId];
        IERC721(originalToken.tokenAddress).transferFrom(
            address(this),
            msg.sender,
            originalToken.tokenId
        );

        emit Unwrapped(
            originalToken.tokenAddress,
            originalToken.tokenId,
            tokenId
        );
    }

    function removeElement(uint256 tokenId, uint256 element) internal {
        for (uint256 i = 0; i < tokenChains[tokenId].length; i++) {
            if (tokenChains[tokenId][i] == element) {
                tokenChains[tokenId][i] = tokenChains[tokenId][
                    tokenChains[tokenId].length - 1
                ];
                tokenChains[tokenId].pop();
                return;
            }
        }
    }
}