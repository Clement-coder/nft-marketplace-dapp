// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract MarketplaceTest is Test {
    NFT nft;
    Marketplace market;
    address seller = address(0x1);
    address buyer = address(0x2);

    function setUp() public {
        nft = new NFT();
        market = new Marketplace();

        // Mint NFT #0 to seller
        vm.startPrank(seller);
        nft.mint(seller);
        vm.stopPrank();
    }

    /// @notice Seller lists an NFT and buyer purchases it
    function testListAndBuy() public {
        vm.startPrank(seller);
        nft.approve(address(market), 0);
        market.listNft(address(nft), 0, 1 ether);
        vm.stopPrank();

        // Check listing stored correctly
        (address lister, uint256 price) = market.getNft(address(nft), 0);
        assertEq(lister, seller);
        assertEq(price, 1 ether);

        // Buyer buys NFT
        vm.deal(buyer, 2 ether);
        vm.startPrank(buyer);
        market.buyNft{value: 1 ether}(address(nft), 0);
        vm.stopPrank();

        // Ownership & payment checks
        assertEq(nft.ownerOf(0), buyer);
        assertEq(seller.balance, 1 ether);

        // Listing removed
        vm.expectRevert(Marketplace.NotListed.selector);
        market.getNft(address(nft), 0);
    }

    /// @notice Buying with not enough ETH reverts
    function testBuyFailsWithInsufficientFunds() public {
        vm.startPrank(seller);
        nft.approve(address(market), 0);
        market.listNft(address(nft), 0, 1 ether);
        vm.stopPrank();

        vm.deal(buyer, 0.5 ether);
        vm.startPrank(buyer);
        vm.expectRevert(Marketplace.NotEnoughEther.selector);
        market.buyNft{value: 0.5 ether}(address(nft), 0);
        vm.stopPrank();
    }

    /// @notice Only NFT owner can list
    function testOnlyOwnerCanList() public {
        vm.startPrank(buyer);
        vm.expectRevert(Marketplace.NotOwner.selector);
        market.listNft(address(nft), 0, 1 ether);
        vm.stopPrank();
    }

    /// @notice Cannot buy an NFT that has already been sold
    function testCannotBuyAlreadySoldNFT() public {
        // Seller lists & buyer buys
        vm.startPrank(seller);
        nft.approve(address(market), 0);
        market.listNft(address(nft), 0, 1 ether);
        vm.stopPrank();

        vm.deal(buyer, 1 ether);
        vm.startPrank(buyer);
        market.buyNft{value: 1 ether}(address(nft), 0);
        vm.stopPrank();

        // Another buyer attempts to buy
        address secondBuyer = address(0x3);
        vm.deal(secondBuyer, 1 ether);
        vm.startPrank(secondBuyer);
        vm.expectRevert(Marketplace.NotListed.selector);
        market.buyNft{value: 1 ether}(address(nft), 0);
        vm.stopPrank();
    }

    /// @notice Listing without approval fails
    function testListWithoutApprovalFails() public {
        vm.startPrank(seller);
        vm.expectRevert(Marketplace.NotApprovedForTransfer.selector);
        market.listNft(address(nft), 0, 1 ether);
        vm.stopPrank();
    }

    /// @notice Seller can remove their own listing
    function testRemoveListing() public {
        vm.startPrank(seller);
        nft.approve(address(market), 0);
        market.listNft(address(nft), 0, 1 ether);

        market.removeNft(address(nft), 0);
        vm.stopPrank();

        vm.expectRevert(Marketplace.NotListed.selector);
        market.getNft(address(nft), 0);
    }

    /// @notice Only owner can remove listing
    function testRemoveListingFailsIfNotOwner() public {
        vm.startPrank(seller);
        nft.approve(address(market), 0);
        market.listNft(address(nft), 0, 1 ether);
        vm.stopPrank();

        vm.startPrank(buyer);
        vm.expectRevert(Marketplace.NotOwner.selector);
        market.removeNft(address(nft), 0);
        vm.stopPrank();
    }

    /// @notice Getting an unlisted NFT fails
    function testGetNftFailsIfNotListed() public {
        vm.expectRevert(Marketplace.NotListed.selector);
        market.getNft(address(nft), 0);
    }
}
