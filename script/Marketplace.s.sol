// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {NFT} from "../src/NFT.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract MarketplaceScript is Script {
    function run() external {
        vm.startBroadcast();

        NFT nft = new NFT();
        Marketplace market = new Marketplace();

        vm.stopBroadcast();
    }
}