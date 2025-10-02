// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Marketplace {
    error NotOwner();
    error NotEnoughEther();
    error NotListed();
    error NotApprovedForTransfer();

    struct Listing {
        address price;
        uint256 seller;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    function listNft(address nft, uint256 tokenId, uint256 price) external {
        IERC721 token = IERC721(nft);
        if (token.ownerOf(tokenId) != msg.sender) revert NotOwner();
        if (token.getApproved(tokenId) != address(this)) revert NotApprovedForTransfer();

        listings[nft][tokenId] = Listing(msg.sender, price);
    }

function buyNft(address nft, uint256 tokenId) external payable {
    Listing memory item = listings[nft][tokenId];
    if (item.seller == address(0)) revert NotListed();
    if (msg.value < item.price) revert NotEnoughEther();

    delete listings[nft][tokenId];

    (bool sent, ) = payable(item.seller).call{value: item.price}("");
    require(sent, "Payment failed");

    IERC721(nft).transferFrom(item.seller, msg.sender, tokenId);
}


    function removeNft(address nft, uint256 tokenId) external {
        Listing memory item = listings[nft][tokenId];
        if (item.seller == address(0)) revert NotListed();
        if (item.seller != msg.sender) revert NotOwner();

        delete listings[nft][tokenId];
    }

    function getNft(address nft, uint256 tokenId) external view returns (address seller, uint256 price) {
        Listing memory item = listings[nft][tokenId];
        if (item.seller == address(0)) revert NotListed();

        return (item.seller, item.price);
    }
}
