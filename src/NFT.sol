// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721 {
    uint256 private _nextTokenId;

    constructor() ERC721("MyNFT", "MNFT") {}

    function mint(address to) external {
        _safeMint(to, _nextTokenId);
        _nextTokenId++;
    }
}
