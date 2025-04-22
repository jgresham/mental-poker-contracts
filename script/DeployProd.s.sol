// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.29;

import { TexasHoldemRoom } from "../src/TexasHoldemRoom.sol";
import { Script, console } from "forge-std/Script.sol";
import { CryptoUtils } from "../src/CryptoUtils.sol";
import { PokerHandEvaluatorv2 } from "../src/PokerHandEvaluatorv2.sol";
import { DeckHandler } from "../src/DeckHandler.sol";

contract DeployProd is Script {
    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        CryptoUtils cryptoUtils = new CryptoUtils();
        PokerHandEvaluatorv2 handEvaluator = new PokerHandEvaluatorv2();
        TexasHoldemRoom room = new TexasHoldemRoom(address(cryptoUtils), uint256(40), false);
        DeckHandler deckHandler =
            new DeckHandler(address(room), address(cryptoUtils), address(handEvaluator));
        room.setDeckHandler(address(deckHandler));

        console.log("Contract TexasHoldemRoom deployed at: %s", address(room));
        console.log("Contract DeckHandler deployed at: %s", address(deckHandler));
        vm.stopBroadcast();
    }
}
