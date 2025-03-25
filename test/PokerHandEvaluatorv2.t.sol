// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {PokerHandEvaluatorv2} from "../src/PokerHandEvaluatorv2.sol";

contract StringComparator {
    function compareStrings(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}

contract PokerHandEvaluatorTest is Test {
    PokerHandEvaluatorv2 public pokerHandEvaluator;

    function setUp() public {
        pokerHandEvaluator = new PokerHandEvaluatorv2();
    }

    function test_bestHandRoyalFlush() public {
        // Royal Flush: 10, J, Q, K, A of the same suit
        // Hearts: 8 (10H), 9 (JH), 10 (QH), 11 (KH), 12 (AH)
        // string[7] memory cards = ["8", "9", "10", "11", "12", "26", "39"];
        string[7] memory cards = ["AH", "9H", "10H", "JH", "QH", "KH", "8H"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Royal Flush hand.rank: %s", uint256(hand.rank));
        console.log("Royal Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.RoyalFlush));
        assertEq(hand.score, 1000000000000000);
    }

    function test_bestHandRoyalFlush2() public {
        // Royal Flush: 10, J, Q, K, A of the same suit
        string[7] memory cards = ["AS", "9H", "10S", "JS", "QS", "KS", "8D"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Royal Flush hand.rank: %s", uint256(hand.rank));
        console.log("Royal Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.RoyalFlush));
        assertEq(hand.score, 1000000000000000);
    }

    function test_bestHandStraightFlush() public {
        // Straight Flush: 5 consecutive cards of the same suit
        string[7] memory cards = ["0", "1", "2", "3", "4", "5", "6"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Straight Flush hand.rank: %s", uint256(hand.rank));
        console.log("Straight Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.StraightFlush));
        assertEq(hand.score, 900000000000006);

        cards = ["0", "2", "3", "4", "5", "6", "7"];
        PokerHandEvaluatorv2.Hand memory hand2 = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Straight Flush hand2.rank: %s", uint256(hand2.rank));
        console.log("Straight Flush hand2.score: %s", hand2.score);
        assertEq(uint256(hand2.rank), uint256(PokerHandEvaluatorv2.HandRank.StraightFlush));
        assertEq(hand2.score, 900000000000008);
        assertTrue(hand2.score > hand.score);
    }

    function test_bestHandStraightFlush2() public {
        // Straight Flush: 5 consecutive cards of the same suit
        string[7] memory cards = ["AC", "9S", "10S", "JS", "QS", "KS", "8D"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Straight Flush hand.rank: %s", uint256(hand.rank));
        console.log("Straight Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.StraightFlush));
        assertEq(hand.score, 900000000000013);
    }

    function test_bestHandFourOfAKind() public {
        // Four of a Kind: 4 cards of the same rank
        // Four 5s (5H, 5D, 5C, 5S) and a 7H
        string[7] memory cards = ["3", "16", "29", "42", "5", "18", "31"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Four of a Kind hand.rank: %s", uint256(hand.rank));
        console.log("Four of a Kind hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.FourOfAKind));
        assertEq(hand.score, 800000000000507);
    }

    function test_bestHandFourOfAKind2() public {
        // Four of a Kind: 4 cards of the same rank
        string[7] memory cards = ["AC", "AS", "10S", "JS", "QS", "AH", "AD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Four of a Kind hand.rank: %s", uint256(hand.rank));
        console.log("Four of a Kind hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.FourOfAKind));
        assertEq(hand.score, 800000000001412);
    }

    function test_bestHandFullHouse() public {
        // Full House: 3 cards of one rank and 2 of another
        // Three 8s (8H, 8D, 8C) and two Ks (KH, KD)
        string[7] memory cards = ["6", "19", "32", "11", "24", "0", "13"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Full House hand.rank: %s", uint256(hand.rank));
        console.log("Full House hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.FullHouse));
        assertEq(hand.score, 700000000000813);
    }

    function test_bestHandFullHouse2() public {
        // Full House: 3 cards of one rank and 2 of another
        string[7] memory cards = ["AC", "AS", "10S", "JS", "2S", "2H", "AD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Full House hand.rank: %s", uint256(hand.rank));
        console.log("Full House hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.FullHouse));
        assertEq(hand.score, 700000000001402);
    }

    function test_bestHandFlush() public {
        // Flush: 5 cards of the same suit, not in sequence
        // 2H, 5H, 7H, 10H, AH, 2C, 5C
        string[7] memory cards = ["0", "3", "5", "8", "12", "26", "29"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Flush hand.rank: %s", uint256(hand.rank));
        console.log("Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.Flush));
        assertEq(hand.score, 600001410070502);
    }

    function test_bestHandFlush2() public {
        // Flush: 5 cards of the same suit, not in sequence
        // also has a three of a kind (but three of a kind is lower rank)
        string[7] memory cards = ["4S", "AS", "10S", "JS", "2S", "AH", "AD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Flush hand.rank: %s", uint256(hand.rank));
        console.log("Flush hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.Flush));
        assertEq(hand.score, 600001411100402); // score is higher than test_bestHandFlush because the 2nd kicker is higher
    }

    function test_bestHandStraight() public {
        // Straight: 5 consecutive cards of mixed suits
        // 5H, 6D, 7C, 8S, 9H
        string[7] memory cards = ["3", "17", "31", "45", "7", "20", "33"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Straight hand.rank: %s", uint256(hand.rank));
        console.log("Straight hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.Straight));
    }

    function test_bestHandStraight2() public {
        // Straight: 5 consecutive cards of mixed suits
        // also has a three of a kind (but three of a kind is lower rank)
        string[7] memory cards = ["5S", "5D", "5H", "4S", "3S", "2D", "AD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Straight hand.rank: %s", uint256(hand.rank));
        console.log("Straight hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.Straight));
        assertEq(hand.score, 500000000000005);
    }

    function test_bestHandThreeOfAKind() public {
        // Three of a Kind: 3 cards of the same rank
        // Three 7s (7H, 7D, 7C) and 4H, 9S, 2C, 3S
        string[7] memory cards = ["5", "18", "31", "2", "45", "26", "40"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Three of a Kind hand.rank: %s", uint256(hand.rank));
        console.log("Three of a Kind hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.ThreeOfAKind));
    }

    function test_bestHandThreeOfAKind2() public {
        // Three of a Kind: 3 cards of the same rank
        string[7] memory cards = ["5S", "5D", "5H", "4S", "3S", "2D", "JD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Three of a Kind hand.rank: %s", uint256(hand.rank));
        console.log("Three of a Kind hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.ThreeOfAKind));
        assertEq(hand.score, 400000005110004);
    }

    function test_bestHandTwoPair() public {
        // Two Pair: 2 cards of one rank, 2 of another
        // Two 4s (4H, 4D) and two Js (JH, JD) and a 2C, 5S, 2H
        string[7] memory cards = ["2", "15", "9", "22", "26", "42", "0"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Two Pair hand.rank: %s", uint256(hand.rank));
        console.log("Two Pair hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.TwoPair));
    }

    function test_bestHandTwoPair2() public {
        // Two Pair: 2 cards of one rank, 2 of another
        string[7] memory cards = ["5S", "5D", "4H", "4S", "3S", "2D", "JD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Two Pair hand.rank: %s", uint256(hand.rank));
        console.log("Two Pair hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.TwoPair));
        assertEq(hand.score, 300000005040011);
    }

    function test_bestHandPair() public {
        // Pair: 2 cards of the same rank
        // Two As (AH, AD) and 3H, 5C, 9S, 2C, 8S
        string[7] memory cards = ["12", "25", "1", "29", "45", "26", "49"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("Pair hand.rank: %s", uint256(hand.rank));
        console.log("Pair hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.Pair));
    }

    function test_bestHandPair2() public {
        // Pair: 2 cards of the same rank
        string[7] memory cards = ["5S", "5D", "7H", "4S", "3S", "2D", "JD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("Two Pair hand.rank: %s", uint256(hand.rank));
        console.log("Two Pair hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.Pair));
        assertEq(hand.score, 200000005040711);
    }

    function test_bestHandHighCard() public {
        // High Card: When no other hand is made
        // AH, 10C, 8D, 5S, 2H, 9C, 3S with different suits
        string[7] memory cards = ["12", "34", "19", "42", "0", "33", "40"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal(cards);
        console.log("High Card hand.rank: %s", uint256(hand.rank));
        console.log("High Card hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.HighCard));
    }

    function test_bestHandHighCard2() public {
        // High Card: When no other hand is made
        string[7] memory cards = ["5S", "7D", "9H", "4S", "3S", "2D", "JD"];
        PokerHandEvaluatorv2.Hand memory hand = pokerHandEvaluator.findBestHandExternal2(cards);
        console.log("High Card hand.rank: %s", uint256(hand.rank));
        console.log("High Card hand.score: %s", hand.score);
        assertEq(uint256(hand.rank), uint256(PokerHandEvaluatorv2.HandRank.HighCard));
        assertEq(hand.score, 100000011097504);
    }
}
