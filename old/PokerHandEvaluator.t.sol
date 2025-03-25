// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {PokerHandEvaluator} from "../src/PokerHandEvaluator.sol";

contract StringComparator {
    function compareStrings(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}

contract PokerHandEvaluatorTest is Test {
    PokerHandEvaluator public pokerHandEvaluator;

    function setUp() public {
        pokerHandEvaluator = new PokerHandEvaluator();
    }

    function test_bestHandRoyalFlush() public {
        // Royal Flush: 10, J, Q, K, A of the same suit
        // Hearts: 8 (10H), 9 (JH), 10 (QH), 11 (KH), 12 (AH)
        string[7] memory cards = ["8", "9", "10", "11", "12", "26", "39"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Royal Flush hand.rank: %s", uint256(hand.rank));
        console.log("Royal Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.RoyalFlush));
        assertEq(hand.score, 1000000000000000);
    }

    function test_bestHandStraightFlush() public {
        // Straight Flush: 5 consecutive cards of the same suit
        string[7] memory cards = ["0", "1", "2", "3", "4", "5", "6"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Straight Flush hand.rank: %s", uint256(hand.rank));
        console.log("Straight Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.StraightFlush));
        assertEq(hand.score, 900000000000006);

        cards = ["0", "2", "3", "4", "5", "6", "7"];
        PokerHandEvaluator.Hand memory hand2 = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Straight Flush hand2.rank: %s", uint256(hand2.rank));
        console.log("Straight Flush hand2.score: %s", hand2.score);
        assertEq(uint256(hand2.rank), uint256(PokerHandEvaluator.HandRank.StraightFlush));
        assertEq(hand2.score, 900000000000008);
        assertTrue(hand2.score > hand.score);
    }

    function test_bestHandFourOfAKind() public {
        // Four of a Kind: 4 cards of the same rank
        // Four 5s (5H, 5D, 5C, 5S) and a 7H
        string[7] memory cards = ["3", "16", "29", "42", "5", "18", "31"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Four of a Kind hand.rank: %s", uint256(hand.rank));
        console.log("Four of a Kind hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.FourOfAKind));
        assertEq(hand.score, 800000000000507);
    }

    function test_bestHandFullHouse() public {
        // Full House: 3 cards of one rank and 2 of another
        // Three 8s (8H, 8D, 8C) and two Ks (KH, KD)
        string[7] memory cards = ["6", "19", "32", "11", "24", "0", "13"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Full House hand.rank: %s", uint256(hand.rank));
        console.log("Full House hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.FullHouse));
        assertEq(hand.score, 700000000000813);
    }

    function test_bestHandFlush() public {
        // Flush: 5 cards of the same suit, not in sequence
        // 2H, 5H, 7H, 10H, AH, 2C, 5C
        string[7] memory cards = ["0", "3", "5", "8", "12", "26", "29"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Flush hand.rank: %s", uint256(hand.rank));
        console.log("Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.Flush));
    }

    function test_bestHandStraight() public {
        // Straight: 5 consecutive cards of mixed suits
        // 5H, 6D, 7C, 8S, 9H
        string[7] memory cards = ["3", "17", "31", "45", "7", "20", "33"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Straight hand.rank: %s", uint256(hand.rank));
        console.log("Straight hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.Straight));
    }

    function test_bestHandThreeOfAKind() public {
        // Three of a Kind: 3 cards of the same rank
        // Three 7s (7H, 7D, 7C) and 2H, 9S
        string[7] memory cards = ["5", "18", "31", "0", "45", "26", "39"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Three of a Kind hand.rank: %s", uint256(hand.rank));
        console.log("Three of a Kind hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.ThreeOfAKind));
    }

    function test_bestHandTwoPair() public {
        // Two Pair: 2 cards of one rank, 2 of another
        // Two 4s (4H, 4D) and two Js (JH, JD) and a 2C
        string[7] memory cards = ["2", "15", "9", "22", "28", "41", "0"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Two Pair hand.rank: %s", uint256(hand.rank));
        console.log("Two Pair hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.TwoPair));
    }

    function test_bestHandPair() public {
        // Pair: 2 cards of the same rank
        // Two As (AH, AD) and 3H, 5C, 9S
        string[7] memory cards = ["12", "25", "1", "29", "45", "26", "39"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Pair hand.rank: %s", uint256(hand.rank));
        console.log("Pair hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.Pair));
    }

    function test_bestHandHighCard() public {
        // High Card: When no other hand is made
        // AH, 10C, 8D, 5S, 2H with different suits
        string[7] memory cards = ["12", "36", "21", "44", "0", "26", "39"];
        PokerHandEvaluator.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("High Card hand.rank: %s", uint256(hand.rank));
        console.log("High Card hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluator.HandRank.HighCard));
    }
}
