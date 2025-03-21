// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/TexasHoldemRoom.sol";
import "../src/PokerHandEvaluator.sol";

contract TexasHoldemRoomTest is Test {
    TexasHoldemRoom public room;
    address public player1;
    address public player2;
    address public player3;
    uint256 constant SMALL_BLIND = 10;
    uint256 constant INITIAL_BALANCE = 1000;

    function setUp() public {
        room = new TexasHoldemRoom(SMALL_BLIND, false);

        // Create test accounts
        player1 = makeAddr("player1");
        player2 = makeAddr("player2");
        player3 = makeAddr("player3");

        // Fund test accounts
        vm.deal(player1, INITIAL_BALANCE);
        vm.deal(player2, INITIAL_BALANCE);
        vm.deal(player3, INITIAL_BALANCE);
    }

    // (gas: 7,682,186)
    // (gas: 4,980,995) w/o initializing deck with BigNumbers = 0
    function test_CreateRoom() public {
        TexasHoldemRoom roomTestCreate = new TexasHoldemRoom(SMALL_BLIND, false);
        (TexasHoldemRoom.GameStage stageRoomTestCreate,,,,,,,,) = roomTestCreate.gameState();
        assertEq(uint256(stageRoomTestCreate), uint256(TexasHoldemRoom.GameStage.Idle));
        assertEq(roomTestCreate.numPlayers(), 0);
    }

    function test_JoinGameWith2PlayersStartsGame() public {
        // Verify that the game state is idle phase
        (TexasHoldemRoom.GameStage stage0,,,,,,,,) = room.gameState();
        assertEq(uint256(stage0), uint256(TexasHoldemRoom.GameStage.Idle));

        // Test joining with player1
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();

        // Verify player1 joined successfully
        (address addr, uint256 chips, uint256 currentBet, bool hasFolded, bool isAllIn) = room.players(0);
        assertEq(addr, player1);
        assertEq(chips, INITIAL_BALANCE);
        assertEq(currentBet, 0);
        assertEq(hasFolded, false);
        assertEq(isAllIn, false);
        assertEq(room.numPlayers(), 1);

        // Verify that the game state is still idle phase
        (TexasHoldemRoom.GameStage stage1,,,,,,,,) = room.gameState();
        assertEq(uint256(stage1), uint256(TexasHoldemRoom.GameStage.Idle));

        // Test joining with player2
        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();

        // Verify player2 joined successfully
        (addr, chips, currentBet, hasFolded, isAllIn) = room.players(1);
        assertEq(addr, player2);
        assertEq(chips, INITIAL_BALANCE);
        assertEq(currentBet, 0);
        assertEq(hasFolded, false);
        assertEq(isAllIn, false);
        assertEq(room.numPlayers(), 2);

        // Verify that the game state is now in the shuffle phase
        (TexasHoldemRoom.GameStage stage2,,,,,,,,) = room.gameState();
        assertEq(uint256(stage2), uint256(TexasHoldemRoom.GameStage.Shuffle));
    }

    // For one player submit: (gas: 3,486,222) to save state (and emit event)
    // For one play submit: (gas: 768,315) to just emit event
    function test_Shuffle2Players() public {
        // Test joining with player1
        vm.startPrank(player1);
        room.joinGame();
        vm.stopPrank();
        // Test joining with player2
        vm.startPrank(player2);
        room.joinGame();
        vm.stopPrank();

        // Verify that the game state is now in the shuffle phase
        TexasHoldemRoom.GameStage stage2 = room.getStage();
        assertEq(uint256(stage2), uint256(TexasHoldemRoom.GameStage.Shuffle));
        assertEq(room.getDealerPosition(), 0);
        assertEq(room.getCurrentPlayerIndex(), 0);

        // The Dealer should be player1
        // and player1 should submit their encrypted shuffle first
        vm.startPrank(player1);
        BigNumber[] memory encryptedShuffle = new BigNumber[](52);
        // initialize with 2048 bits of random data for each card
        for (uint256 i = 0; i < 52; i++) {
            bytes memory cardBytes = abi.encodePacked(bytes32(uint256(i)));
            // Use the contract's instance to call init
            encryptedShuffle[i] = BigNumbers.init(cardBytes, false, 2048);
        }
        room.submitEncryptedShuffle(encryptedShuffle);
        vm.stopPrank();

        assertEq(room.getDealerPosition(), 0);
        assertEq(room.getCurrentPlayerIndex(), 1);

        // TODO: encryptions should be calculated from player1's encrypted shuffle
        // player2 should submit their encrypted shuffle next
        vm.startPrank(player2);
        // initialize with 2048 bits of random data for each card
        for (uint256 i = 0; i < 52; i++) {
            bytes memory cardBytes = abi.encodePacked(bytes32(uint256(1000 + i)));
            // Use the contract's instance to call init
            encryptedShuffle[i] = BigNumbers.init(cardBytes, false, 2048);
        }
        room.submitEncryptedShuffle(encryptedShuffle);
        vm.stopPrank();

        // Verify that the game state is now in the deal phase
        (TexasHoldemRoom.GameStage stage3,,,,,,,,) = room.gameState();
        assertEq(uint256(stage3), uint256(TexasHoldemRoom.GameStage.RevealDeal));
        assertEq(room.getDealerPosition(), 0);
        assertEq(room.getCurrentPlayerIndex(), 0);

        // player 1 should submit their decryption values for player 2's cards
        vm.startPrank(player1);
        // the encrypted values submitted are not correct at the moment
        // submit card index and decrypted value for each card
        // card 0 to p1, card 1 to p2, card 2 to p1, card 3 to p2!
        uint8[] memory cardIndexes = new uint8[](2);
        cardIndexes[0] = 1;
        cardIndexes[1] = 3;
        BigNumber[] memory decryptionValues = new BigNumber[](2);
        decryptionValues[0] = encryptedShuffle[1];
        decryptionValues[1] = encryptedShuffle[3];
        room.submitDecryptionValues(cardIndexes, decryptionValues);
        vm.stopPrank();

        assertEq(room.getCurrentPlayerIndex(), 1);

        // player 2 should submit their decryption values for player 1's cards
        vm.startPrank(player2);
        cardIndexes[0] = 0;
        cardIndexes[1] = 2;
        decryptionValues[0] = encryptedShuffle[0];
        decryptionValues[1] = encryptedShuffle[2];
        room.submitDecryptionValues(cardIndexes, decryptionValues);
        vm.stopPrank();

        // Verify that the game state is now in the preflop phase
        (TexasHoldemRoom.GameStage stage4,,,,,,,,) = room.gameState();
        assertEq(uint256(stage4), uint256(TexasHoldemRoom.GameStage.Preflop));
        // the first active player LEFT of the dealer starts all betting stages
        assertEq(room.getCurrentPlayerIndex(), 1);

        // TODO: verify that each player can decrypt their cards

        // TODO: start preflop betting
        // player 1 should submit their action
        vm.startPrank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();

        assertEq(room.getCurrentPlayerIndex(), 1);

        // player 2 should submit their action
        vm.startPrank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.stopPrank();

        // We should be in the reveal flop phase now
        assertEq(uint256(room.getStage()), uint256(TexasHoldemRoom.GameStage.RevealFlop));
        // The dealer starts all reveal stages
        assertEq(room.getCurrentPlayerIndex(), 0);

        // All players should submit their decryption values for the flop cards
        uint8[] memory cardIndexesFlop = new uint8[](3);
        BigNumber[] memory decryptionValuesFlop = new BigNumber[](3);
        // player 1 should submit their decryption values for player 2's cards
        vm.startPrank(player1);
        // 2 players, 5th card is burned, 678 are the flop cards
        cardIndexesFlop[0] = 5;
        cardIndexesFlop[1] = 6;
        cardIndexesFlop[2] = 7;
        decryptionValuesFlop[0] = encryptedShuffle[5];
        decryptionValuesFlop[1] = encryptedShuffle[6];
        decryptionValuesFlop[2] = encryptedShuffle[7];
        room.submitDecryptionValues(cardIndexesFlop, decryptionValuesFlop);
        vm.stopPrank();

        assertEq(room.getCurrentPlayerIndex(), 1);

        // 2 players, 5th card is burned, 678 are the flop cards
        vm.startPrank(player2);
        cardIndexesFlop[0] = 5;
        cardIndexesFlop[1] = 6;
        cardIndexesFlop[2] = 7;
        decryptionValuesFlop[0] = encryptedShuffle[5];
        decryptionValuesFlop[1] = encryptedShuffle[6];
        decryptionValuesFlop[2] = encryptedShuffle[7];
        room.submitDecryptionValues(cardIndexesFlop, decryptionValuesFlop);
        vm.stopPrank();

        // We should be in the flop phase now
        assertEq(room.getCurrentPlayerIndex(), 0);
        assertEq(uint256(room.getStage()), uint256(TexasHoldemRoom.GameStage.Flop));
    }

    function test_JoinGameFailures() public {
        // Test joining twice
        vm.startPrank(player1);
        room.joinGame();
        vm.expectRevert("Already in game");
        room.joinGame();
        vm.stopPrank();
    }

    function test_StartNewHand() public {
        // Setup: Join two players
        vm.prank(player1);
        room.joinGame();
        vm.prank(player2);
        room.joinGame();

        // Start new hand
        vm.prank(player1);
        room.startNewHand();

        // Verify game state
        (
            TexasHoldemRoom.GameStage stage,
            uint256 pot,
            uint256 currentBet,
            uint256 smallBlind,
            uint256 bigBlind,
            uint256 dealerPosition,
            uint256 currentPlayerIndex,
            uint256 lastRaiseIndex,
            uint256 revealedCommunityCards
        ) = room.gameState();

        assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.Preflop));
        assertEq(pot, SMALL_BLIND + SMALL_BLIND * 2); // SB + BB
        assertEq(currentBet, SMALL_BLIND * 2); // BB amount
        assertEq(dealerPosition, 0);
        assertEq(currentPlayerIndex, 0); // First player after BB
    }

    function test_StartNewHandFailures() public {
        // Test starting with only one player
        vm.startPrank(player1);
        room.joinGame();
        vm.expectRevert("Not enough players");
        room.startNewHand();
        vm.stopPrank();
    }

    function test_PlayerActions() public {
        // Setup: Join three players and start hand
        vm.prank(player1);
        room.joinGame();
        vm.prank(player2);
        room.joinGame();
        vm.prank(player3);
        room.joinGame();

        vm.prank(player1);
        room.startNewHand();

        // Test fold action
        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Fold, 0);

        // Test call action
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);

        // Test raise action
        vm.prank(player3);
        room.submitAction(TexasHoldemRoom.Action.Raise, SMALL_BLIND * 4);

        // Verify game state after actions
        (, uint256 pot, uint256 currentBet,,,,,, uint256 revealedCommunityCards) = room.gameState();

        assertEq(currentBet, SMALL_BLIND * 4);
        assertEq(pot, SMALL_BLIND + SMALL_BLIND * 2 + SMALL_BLIND * 4);
    }

    function test_PlayerActionFailures() public {
        // Setup game
        vm.prank(player1);
        room.joinGame();
        vm.prank(player2);
        room.joinGame();

        vm.prank(player1);
        room.startNewHand();

        // Test acting out of turn
        vm.prank(player2);
        vm.expectRevert("Not your turn");
        room.submitAction(TexasHoldemRoom.Action.Call, 0);

        // Test invalid raise amount
        vm.prank(player1);
        vm.expectRevert("Raise must be higher than current bet");
        room.submitAction(TexasHoldemRoom.Action.Raise, SMALL_BLIND);
    }

    function test_GameProgression() public {
        // Setup game
        vm.prank(player1);
        room.joinGame();
        vm.prank(player2);
        room.joinGame();

        vm.prank(player1);
        room.startNewHand();

        // Submit actions to progress through stages
        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        // Verify we're in flop stage
        (TexasHoldemRoom.GameStage stage,,,,,,,, uint256 revealedCommunityCards) = room.gameState();
        assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.Flop));

        // Continue through turn and river
        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        (stage,,,,,,,, revealedCommunityCards) = room.gameState();
        assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.Turn));

        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        (stage,,,,,,,, revealedCommunityCards) = room.gameState();
        assertEq(uint256(stage), uint256(TexasHoldemRoom.GameStage.River));
    }

    function test_HandReveal() public {
        // Setup game
        vm.prank(player1);
        room.joinGame();
        vm.prank(player2);
        room.joinGame();

        vm.prank(player1);
        room.startNewHand();

        // Progress to showdown
        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Call, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        vm.prank(player1);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);
        vm.prank(player2);
        room.submitAction(TexasHoldemRoom.Action.Check, 0);

        // Test hand reveal
        PokerHandEvaluator.Card[2] memory cards = [
            PokerHandEvaluator.Card(14, 0), // Ace of Hearts
            PokerHandEvaluator.Card(13, 0) // King of Hearts
        ];
        bytes32 secret = bytes32(uint256(1));
        bytes32 commitment = keccak256(abi.encode(cards, secret));

        vm.startPrank(player1);
        room.submitHoleCardCommitment(commitment);
        room.revealHoleCards(cards, secret);
        vm.stopPrank();
    }

    receive() external payable {}
}
