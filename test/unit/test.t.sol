// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/LendBorrow.sol";
import "../../src/Bridge.sol";
import "../../src/NFT.sol";

contract CounterTest is Test {
    LendBorrow lendborrowcontract;
    Bridge bridge;
    SimpleNFT nft;

    address public immutable owner =
        address(0x0D9f77503dA9d5EC2497b1619Fc3c04464309859);

    function setUp() public {}

    function testDeposit() public {
        vm.createSelectFork("sepolia");
        vm.deal(address(owner), 1000 ether);
        vm.startPrank(owner);
        lendborrowcontract = new LendBorrow(address(owner));
        bridge = new Bridge(
            0xCC737a94FecaeC165AbCf12dED095BB13F037685,
            0x8f9C3888bFC8a5B25AED115A82eCbb788b196d2a,
            payable(address(lendborrowcontract))
        );
        // vm.deal(payable(address(bridge)),1 ether);
        vm.deal(payable(address(lendborrowcontract)),1 ether);
        lendborrowcontract.setBridge(payable(address(bridge)));
        nft = new SimpleNFT();
        nft.mint(address(owner));
        uint256 tokenid = nft.tokenOfOwnerByIndex(address(owner), 0);
        lendborrowcontract.floorPriceOfNFT(address(nft), tokenid,100 ether);
        nft.approve(address(lendborrowcontract), tokenid);
        lendborrowcontract.depositNFT(address(nft), tokenid);
        vm.stopPrank();
    }
}
