// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {PokerHandEvaluatorv2} from "../src/PokerHandEvaluatorv2.sol";

contract StringComparator {
    function compareStrings(string memory _a, string memory _b) public pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}

contract PokerHandEvaluatorUtilsTest is Test {
    PokerHandEvaluatorv2 public pokerHandEvaluator;

    function setUp() public {
        pokerHandEvaluator = new PokerHandEvaluatorv2();
    }

    function test_stringToCard() public view {
        string memory cardStr = "0";
        PokerHandEvaluatorv2.Card memory card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 2);
        assertEq(card.suit, 0);
    }

    function test_stringToHumanReadable() public view {
        string memory cardStr = "0";
        string memory humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "2H");
    }

    function test_humanReadableToCard() public view {
        string memory cardStr = "2H";
        PokerHandEvaluatorv2.Card memory card = pokerHandEvaluator.humanReadableToCard(cardStr);
        assertEq(card.rank, 2);
        assertEq(card.suit, 0);
        cardStr = "AH";
        card = pokerHandEvaluator.humanReadableToCard(cardStr);
        assertEq(card.rank, 14);
        assertEq(card.suit, 0);
        cardStr = "10D";
        card = pokerHandEvaluator.humanReadableToCard(cardStr);
        assertEq(card.rank, 10);
        assertEq(card.suit, 1);
        cardStr = "JC";
        card = pokerHandEvaluator.humanReadableToCard(cardStr);
        assertEq(card.rank, 11);
        assertEq(card.suit, 2);
        cardStr = "7S";
        card = pokerHandEvaluator.humanReadableToCard(cardStr);
        assertEq(card.rank, 7);
        assertEq(card.suit, 3);
    }

    function test_stringToCardEveryCard() public view {
        string memory cardStr = "0";
        PokerHandEvaluatorv2.Card memory card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 2);
        assertEq(card.suit, 0);
        cardStr = "1";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 3);
        assertEq(card.suit, 0);
        cardStr = "2";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 4);
        assertEq(card.suit, 0);
        cardStr = "3";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 5);
        assertEq(card.suit, 0);
        cardStr = "4";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 6);
        assertEq(card.suit, 0);
        cardStr = "5";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 7);
        assertEq(card.suit, 0);
        cardStr = "6";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 8);
        assertEq(card.suit, 0);
        cardStr = "7";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 9);
        assertEq(card.suit, 0);
        cardStr = "8";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 10);
        assertEq(card.suit, 0);
        cardStr = "9";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 11);
        assertEq(card.suit, 0);
        cardStr = "10";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 12);
        assertEq(card.suit, 0);
        cardStr = "11";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 13);
        assertEq(card.suit, 0);
        cardStr = "12"; // ace of hearts
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 14);
        assertEq(card.suit, 0);
        cardStr = "13"; // 2 of diamonds
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 2);
        assertEq(card.suit, 1);
        cardStr = "14";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 3);
        assertEq(card.suit, 1);
        cardStr = "15";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 4);
        assertEq(card.suit, 1);
        cardStr = "16";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 5);
        assertEq(card.suit, 1);
        cardStr = "17";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 6);
        assertEq(card.suit, 1);
        cardStr = "18";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 7);
        assertEq(card.suit, 1);
        cardStr = "19";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 8);
        assertEq(card.suit, 1);
        cardStr = "20";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 9);
        assertEq(card.suit, 1);
        cardStr = "21";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 10);
        assertEq(card.suit, 1);
        cardStr = "22";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 11);
        assertEq(card.suit, 1);
        cardStr = "23";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 12);
        assertEq(card.suit, 1);
        cardStr = "24";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 13);
        assertEq(card.suit, 1);
        cardStr = "25"; // ace of diamonds
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 14);
        assertEq(card.suit, 1);
        cardStr = "26"; // 2 of clubs
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 2);
        assertEq(card.suit, 2);
        cardStr = "27";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 3);
        assertEq(card.suit, 2);
        cardStr = "28";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 4);
        assertEq(card.suit, 2);
        cardStr = "29";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 5);
        assertEq(card.suit, 2);
        cardStr = "30";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 6);
        assertEq(card.suit, 2);
        cardStr = "31";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 7);
        assertEq(card.suit, 2);
        cardStr = "32";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 8);
        assertEq(card.suit, 2);
        cardStr = "33";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 9);
        assertEq(card.suit, 2);
        cardStr = "34";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 10);
        assertEq(card.suit, 2);
        cardStr = "35";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 11);
        assertEq(card.suit, 2);
        cardStr = "36";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 12);
        assertEq(card.suit, 2);
        cardStr = "37";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 13);
        assertEq(card.suit, 2);
        cardStr = "38"; // ace of clubs
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 14);
        assertEq(card.suit, 2);
        cardStr = "39"; // 2 of spades
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 2);
        assertEq(card.suit, 3);
        cardStr = "40";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 3);
        assertEq(card.suit, 3);
        cardStr = "41";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 4);
        assertEq(card.suit, 3);
        cardStr = "42";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 5);
        assertEq(card.suit, 3);
        cardStr = "43";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 6);
        assertEq(card.suit, 3);
        cardStr = "44";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 7);
        assertEq(card.suit, 3);
        cardStr = "45";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 8);
        assertEq(card.suit, 3);
        cardStr = "46";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 9);
        assertEq(card.suit, 3);
        cardStr = "47";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 10);
        assertEq(card.suit, 3);
        cardStr = "48";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 11);
        assertEq(card.suit, 3);
        cardStr = "49";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 12);
        assertEq(card.suit, 3);
        cardStr = "50";
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 13);
        assertEq(card.suit, 3);
        cardStr = "51"; // ace of spades
        card = pokerHandEvaluator.stringToCard(cardStr);
        assertEq(card.rank, 14);
        assertEq(card.suit, 3);
    }

    function test_stringToHumanReadableEveryCard() public view {
        string memory cardStr = "0";
        string memory humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "2H");
        cardStr = "1";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "3H");
        cardStr = "2";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "4H");
        cardStr = "3";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "5H");
        cardStr = "4";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "6H");
        cardStr = "5";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "7H");
        cardStr = "6";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "8H");
        cardStr = "7";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "9H");
        cardStr = "8";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "10H");
        cardStr = "9";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "JH");
        cardStr = "10";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "QH");
        cardStr = "11";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "KH");
        cardStr = "12";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "AH");

        // Diamonds
        cardStr = "13";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "2D");
        cardStr = "14";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "3D");
        cardStr = "15";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "4D");
        cardStr = "16";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "5D");
        cardStr = "17";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "6D");
        cardStr = "18";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "7D");
        cardStr = "19";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "8D");
        cardStr = "20";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "9D");
        cardStr = "21";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "10D");
        cardStr = "22";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "JD");
        cardStr = "23";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "QD");
        cardStr = "24";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "KD");
        cardStr = "25";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "AD");

        // Clubs
        cardStr = "26";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "2C");
        cardStr = "27";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "3C");
        cardStr = "28";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "4C");
        cardStr = "29";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "5C");
        cardStr = "30";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "6C");
        cardStr = "31";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "7C");
        cardStr = "32";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "8C");
        cardStr = "33";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "9C");
        cardStr = "34";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "10C");
        cardStr = "35";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "JC");
        cardStr = "36";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "QC");
        cardStr = "37";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "KC");
        cardStr = "38";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "AC");

        // Spades
        cardStr = "39";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "2S");
        cardStr = "40";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "3S");
        cardStr = "41";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "4S");
        cardStr = "42";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "5S");
        cardStr = "43";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "6S");
        cardStr = "44";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "7S");
        cardStr = "45";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "8S");
        cardStr = "46";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "9S");
        cardStr = "47";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "10S");
        cardStr = "48";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "JS");
        cardStr = "49";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "QS");
        cardStr = "50";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "KS");
        cardStr = "51";
        humanReadable = pokerHandEvaluator.stringToHumanReadable(cardStr);
        assertEq(humanReadable, "AS");
    }

    function test_uintToString() public view {
        uint8 value = 10;
        string memory str = pokerHandEvaluator.uintToString(value);
        assertEq(str, "10");
        value = 0;
        str = pokerHandEvaluator.uintToString(value);
        assertEq(str, "0");
        value = 1;
        str = pokerHandEvaluator.uintToString(value);
        assertEq(str, "1");
        value = 11;
        str = pokerHandEvaluator.uintToString(value);
        assertEq(str, "11");
    }
}
