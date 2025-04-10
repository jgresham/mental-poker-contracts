// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { TexasHoldemRoom } from "../src/TexasHoldemRoom.sol";
import { Script } from "forge-std/Script.sol";
import { CryptoUtils } from "../src/CryptoUtils.sol";
import { PokerHandEvaluatorv2 } from "../src/PokerHandEvaluatorv2.sol";

contract DeployAll is Script {
    address player1 = address(0x1);
    address player2 = address(0x2);

    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        CryptoUtils cryptoUtils = new CryptoUtils();
        PokerHandEvaluatorv2 handEvaluator = new PokerHandEvaluatorv2();
        TexasHoldemRoom room =
            new TexasHoldemRoom(address(cryptoUtils), address(handEvaluator), uint256(40), false);

        // untested
        // vm.prank(player1);
        // room.joinGame();
        // vm.prank(player2);
        // room.joinGame();
        // Player[] memory players = room.getPlayers();
        // console.log("Players in the game:");
        // for (uint256 i = 0; i < players.length; i++) {
        //     console.log("Player %d:", i);
        //     console.log("  Address: %s", players[i].addr);
        //     console.log("  Chips: %d", players[i].chips);

        vm.stopBroadcast();
    }
}
