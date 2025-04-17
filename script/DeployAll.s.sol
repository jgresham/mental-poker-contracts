// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import { TexasHoldemRoom } from "../src/TexasHoldemRoom.sol";
import { Script, console } from "forge-std/Script.sol";
import { CryptoUtils } from "../src/CryptoUtils.sol";
import { PokerHandEvaluatorv2 } from "../src/PokerHandEvaluatorv2.sol";
import { DeckHandler } from "../src/DeckHandler.sol";

contract DeployAll is Script {
    address player1 = address(0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f);
    address player2 = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

    function run() public {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        CryptoUtils cryptoUtils = new CryptoUtils();
        PokerHandEvaluatorv2 handEvaluator = new PokerHandEvaluatorv2();
        TexasHoldemRoom room =
            new TexasHoldemRoom(address(cryptoUtils), address(handEvaluator), uint256(40), false);
        DeckHandler deckHandler = new DeckHandler(address(room), address(cryptoUtils));
        room.setDeckHandler(address(deckHandler));
        vm.stopBroadcast();
        vm.startBroadcast(0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97);
        room.joinGame();
        vm.stopBroadcast();
        vm.startBroadcast(0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6);
        // untested
        // vm.prank(player1);
        room.joinGame();
        // vm.stopBroadcast();
        // vm.prank(player2);
        // room.joinGame();
        TexasHoldemRoom.Player[] memory players = room.getPlayers();
        console.log("Players in the game:");
        for (uint256 i = 0; i < players.length; i++) {
            console.log("Player %d:", i);
            console.log("  Address: %s", players[i].addr);
            console.log("  Chips: %d", players[i].chips);
        }

        console.log("Contract TexasHoldemRoom deployed at: %s", address(room));
        console.log("Contract DeckHandler deployed at: %s", address(deckHandler));
        vm.stopBroadcast();
    }
}
