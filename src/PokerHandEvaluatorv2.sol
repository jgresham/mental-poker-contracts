// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

contract PokerHandEvaluatorv2 {
    event PHE_Log(string message);

    enum HandRank {
        HighCard, // 0
        Pair, // 1
        TwoPair, // 2
        ThreeOfAKind, // 3
        Straight, // 4
        Flush, // 5
        FullHouse, // 6
        FourOfAKind, // 7
        StraightFlush, // 8
        RoyalFlush // 9

    }

    struct Card {
        uint8 rank; // 2-14 (14 = AceHigh)
        uint8 suit; // 0-3 (Hearts, Diamonds, Clubs, Spades)
    }

    struct Hand {
        HandRank rank;
        uint256 score;
        Card[5] bestHand;
    }

    function uintToString(uint8 value) public pure returns (string memory) {
        // Special case for 0
        if (value == 0) {
            return "0";
        }

        // Find length of number by counting digits
        uint8 length = 0;
        uint8 temp = value;
        while (temp != 0) {
            length++;
            temp /= 10;
        }

        // Create bytes array of the right length
        bytes memory buffer = new bytes(length);

        // Fill buffer from right to left
        uint8 i = length;
        while (value != 0) {
            buffer[--i] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }

        return string(buffer);
    }

    /**
     * @dev Converts a card string representation (0-51) to a Card struct
     * @param cardStr The string representation of the card (0-51)
     * @return A Card struct with the appropriate rank and suit
     *
     * Card mapping:
     * - Hearts: 0-12 (2-A)
     * - Diamonds: 13-25 (2-A)
     * - Clubs: 26-38 (2-A)
     * - Spades: 39-51 (2-A)
     */
    function stringToCard(string memory cardStr) public pure returns (Card memory) {
        require(
            bytes(cardStr).length == 1 || bytes(cardStr).length == 2, "Invalid card string length"
        );
        uint8 cardNum = uint8(parseInt(cardStr));
        require(cardNum < 52, "Invalid card number");

        uint8 suit = cardNum / 13;
        uint8 rank = cardNum % 13 + 2; // Add 2 because ranks start at 2

        return Card({ rank: rank, suit: suit });
    }

    /**
     * @dev Converts a card string representation (0-51) to a string
     * @param cardStr The string representation of the card (0-51)
     * @return A string with the appropriate rank and suit
     *
     * Card mapping:
     * - Hearts: 0-12 (2-A)
     * - Diamonds: 13-25 (2-A)
     * - Clubs: 26-38 (2-A)
     * - Spades: 39-51 (2-A)
     */
    function stringToHumanReadable(string memory cardStr) public pure returns (string memory) {
        uint8 cardNum = uint8(parseInt(cardStr));
        require(cardNum < 52, "Invalid card number");

        uint8 suit = cardNum / 13;
        uint8 rank = cardNum % 13 + 2; // Add 2 because ranks start at 2
        string memory suitStr;
        if (suit <= 0) {
            suitStr = "H";
        } else if (suit <= 1) {
            suitStr = "D";
        } else if (suit <= 2) {
            suitStr = "C";
        } else {
            suitStr = "S";
        }
        string memory rankStr;
        if (rank <= 10) {
            rankStr = uintToString(rank);
        } else if (rank == 11) {
            rankStr = "J";
        } else if (rank == 12) {
            rankStr = "Q";
        } else if (rank == 13) {
            rankStr = "K";
        } else {
            rankStr = "A";
        }
        return string.concat(rankStr, suitStr);
    }

    /**
     * @dev Converts a human readable card string to a Card struct
     * @dev Example: "2H" -> Card(2, 0)
     * @dev Example: "AH" -> Card(14, 0)
     * @dev Example: "10D" -> Card(21, 1)
     * @param cardStr The human readable card string
     * @return A Card struct with the appropriate rank and suit
     */
    function humanReadableToCard(string memory cardStr) public pure returns (Card memory) {
        bytes memory cardBytes = bytes(cardStr);
        string memory rankStr;
        string memory suitStr = new string(1);

        if (cardBytes.length > 2 && cardBytes[0] == "1" && cardBytes[1] == "0") {
            // Handle "10" as a special case
            rankStr = "10";
            bytes(suitStr)[0] = cardBytes[2];
        } else {
            // For all other cards, just take the first character
            bytes(suitStr)[0] = cardBytes[cardBytes.length - 1];
            rankStr = new string(1);
            bytes(rankStr)[0] = cardBytes[0];
            // if rank is J, Q, K, A
            if (cardBytes[0] == "J") {
                rankStr = "11";
            } else if (cardBytes[0] == "Q") {
                rankStr = "12";
            } else if (cardBytes[0] == "K") {
                rankStr = "13";
            } else if (cardBytes[0] == "A") {
                rankStr = "14";
            }
        }

        uint8 rank = uint8(parseInt(rankStr));
        uint8 suit = 0;
        if (strEq(suitStr, "H")) {
            suit = 0;
        } else if (strEq(suitStr, "D")) {
            suit = 1;
        } else if (strEq(suitStr, "C")) {
            suit = 2;
        } else if (strEq(suitStr, "S")) {
            suit = 3;
        }
        return Card({ rank: rank, suit: suit });
    }

    /**
     * @dev Helper function to parse a string to an integer
     * @param s The string to parse
     * @return The parsed integer value
     */
    function parseInt(string memory s) public pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function evaluateHand(Card[2] memory holeCards, Card[5] memory communityCards)
        public
        pure
        returns (Hand memory)
    {
        Card[7] memory allCards;
        allCards[0] = holeCards[0];
        allCards[1] = holeCards[1];
        for (uint256 i = 0; i < 5; i++) {
            allCards[i + 2] = communityCards[i];
        }

        return findBestHand(allCards);
    }

    function findBestHandExternal(string[7] memory cards) public pure returns (Hand memory) {
        Card[7] memory cardArray;
        for (uint256 i = 0; i < 7; i++) {
            cardArray[i] = stringToCard(cards[i]);
        }
        return findBestHand(cardArray);
    }

    // For test cases to use human readable strings
    function findBestHandExternal2(string[7] memory cards) public pure returns (Hand memory) {
        Card[7] memory cardArray;
        for (uint256 i = 0; i < 7; i++) {
            cardArray[i] = humanReadableToCard(cards[i]);
        }
        return findBestHand(cardArray);
    }

    // TODO(medium): have this return the indicies for the best hand (5 card indicies)
    function findBestHand(Card[7] memory cards) internal pure returns (Hand memory) {
        // Sort cards by rank (ascending order)
        // Example: [2♥, 3♠, 5♦, 8♣, 10♥, J♦, A♠]
        // Cards are sorted from lowest to highest rank
        for (uint256 i = 0; i < cards.length - 1; i++) {
            for (uint256 j = 0; j < cards.length - i - 1; j++) {
                if (cards[j].rank > cards[j + 1].rank) {
                    Card memory temp = cards[j];
                    cards[j] = cards[j + 1];
                    cards[j + 1] = temp;
                }
            }
        }
        // emit PHE_Log("after card creation loop ");

        // Check for each hand type from highest to lowest
        Hand memory bestHand;
        uint256 score = 0;
        uint8 rank = 0;

        // Check Royal Flush
        (rank, score) = hasRoyalFlush(cards);
        if (score > 0) {
            bestHand.rank = HandRank.RoyalFlush;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after royal flush ");

        // Check Straight Flush
        (rank, score) = hasStraightFlush(cards);
        if (score > 0) {
            bestHand.rank = HandRank.StraightFlush;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after straight flush ");
        // Check Four of a Kind
        (rank, score) = hasFourOfAKind(cards);
        if (score > 0) {
            bestHand.rank = HandRank.FourOfAKind;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after four of a kind ");
        // Check Full House
        (rank, score) = hasFullHouse(cards);
        if (score > 0) {
            bestHand.rank = HandRank.FullHouse;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after full house ");
        // Check Flush
        (rank, score) = hasFlush(cards);
        if (score > 0) {
            bestHand.rank = HandRank.Flush;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after flush ");
        // Check Straight
        (rank, score) = hasStraight(cards);
        if (score > 0) {
            bestHand.rank = HandRank.Straight;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after straight ");
        // Check Three of a Kind
        (rank, score) = hasThreeOfAKind(cards);
        if (score > 0) {
            bestHand.rank = HandRank.ThreeOfAKind;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after three of a kind ");
        // Check Two Pair
        (rank, score) = hasTwoPair(cards);
        if (score > 0) {
            bestHand.rank = HandRank.TwoPair;
            bestHand.score = score;
            // emit PHE_Log("has two pair! before return ");
            return bestHand;
        }
        // emit PHE_Log("after two pair ");

        // Check Pair
        (rank, score) = hasPair(cards);
        if (score > 0) {
            bestHand.rank = HandRank.Pair;
            bestHand.score = score;
            return bestHand;
        }
        // emit PHE_Log("after pair ");
        // Default to high card if no other hand is found
        (rank, score) = hasHighCard(cards);
        bestHand.rank = HandRank.HighCard;
        bestHand.score = score;
        // emit PHE_Log("after high card ");
        return bestHand;
    }

    function hasRoyalFlush(Card[7] memory cards) internal pure returns (uint8, uint256) {
        for (uint8 suit = 0; suit < 4; suit++) {
            bool hasAce = false;
            bool hasKing = false;
            bool hasQueen = false;
            bool hasJack = false;
            bool hasTen = false;

            for (uint8 i = 0; i < 7; i++) {
                if (cards[i].suit == suit) {
                    if (cards[i].rank == 14) hasAce = true;
                    if (cards[i].rank == 13) hasKing = true;
                    if (cards[i].rank == 12) hasQueen = true;
                    if (cards[i].rank == 11) hasJack = true;
                    if (cards[i].rank == 10) hasTen = true;
                }
            }

            if (hasAce && hasKing && hasQueen && hasJack && hasTen) {
                return (10, 10 * 10 ** 14);
            }
        }
        return (0, 0);
    }

    function hasStraightFlush(Card[7] memory cards) internal pure returns (uint8, uint256) {
        for (uint8 suit = 0; suit < 4; suit++) {
            uint8[] memory suitCards = new uint8[](7);
            uint8 suitCount = 0;

            for (uint256 i = 0; i < 7; i++) {
                if (cards[i].suit == suit) {
                    suitCards[suitCount] = cards[i].rank;
                    suitCount++;
                }
            }
            if (suitCount >= 5) {
                // Sort suit cards
                for (uint8 i = 0; i < suitCount - 1; i++) {
                    for (uint8 j = 0; j < suitCount - i - 1; j++) {
                        if (suitCards[j] > suitCards[j + 1]) {
                            uint8 temp = suitCards[j];
                            suitCards[j] = suitCards[j + 1];
                            suitCards[j + 1] = temp;
                        }
                    }
                }

                // Check for straight in suited cards
                for (uint8 i = 0; i <= suitCount - 5; i++) {
                    if (suitCards[i + 4] == suitCards[i] + 4) {
                        return (9, 9 * 10 ** 14 + suitCards[i + 4]);
                    }
                }
            }
        }
        return (0, 0);
    }

    function hasFourOfAKind(Card[7] memory cards) internal pure returns (uint8, uint256) {
        for (uint256 i = 0; i < 7; i++) {
            uint8 count = 0;
            uint8 rank = cards[i].rank;

            for (uint256 j = 0; j < 7; j++) {
                if (cards[j].rank == rank) {
                    count++;
                }
            }

            if (count == 4) {
                // Find highest kicker
                uint8 kicker = 0;
                for (uint256 k = 0; k < 7; k++) {
                    if (cards[k].rank != rank && cards[k].rank > kicker) {
                        kicker = cards[k].rank;
                    }
                }
                return (8, 8 * 10 ** 14 + uint256(rank) * 10 ** 2 + uint256(kicker));
            }
        }
        return (0, 0);
    }

    function hasFullHouse(Card[7] memory cards) internal pure returns (uint8, uint256) {
        uint8 threeOfAKindRank = 0;
        uint8 pairRank = 0;

        // Find three of a kind
        for (uint256 i = 0; i < 7; i++) {
            uint8 count = 0;
            uint8 rank = cards[i].rank;

            for (uint256 j = 0; j < 7; j++) {
                if (cards[j].rank == rank) {
                    count++;
                }
            }

            if (count >= 3 && rank > threeOfAKindRank) {
                threeOfAKindRank = rank;
            }
        }

        if (threeOfAKindRank == 0) {
            return (0, 0);
        }

        // Find pair (different from three of a kind)
        for (uint256 i = 0; i < 7; i++) {
            if (cards[i].rank != threeOfAKindRank) {
                uint8 count = 0;
                uint8 rank = cards[i].rank;

                for (uint256 j = 0; j < 7; j++) {
                    if (cards[j].rank == rank) {
                        count++;
                    }
                }

                if (count >= 2 && rank > pairRank) {
                    pairRank = rank;
                }
            }
        }

        if (pairRank > 0) {
            return (7, 7 * 10 ** 14 + uint256(threeOfAKindRank) * 10 ** 2 + uint256(pairRank));
        }

        return (0, 0);
    }

    function hasFlush(Card[7] memory cards) internal pure returns (uint8, uint256) {
        uint8[5] memory flushCards;

        for (uint8 suit = 0; suit < 4; suit++) {
            uint8[] memory suitCards = new uint8[](7);
            uint8 suitCount = 0;

            for (uint8 i = 0; i < 7; i++) {
                if (cards[i].suit == suit) {
                    suitCards[suitCount] = cards[i].rank;
                    suitCount++;
                }
            }

            if (suitCount >= 5) {
                // Sort suit cards in descending order
                for (uint8 i = 0; i < suitCount - 1; i++) {
                    for (uint8 j = 0; j < suitCount - i - 1; j++) {
                        if (suitCards[j] < suitCards[j + 1]) {
                            uint8 temp = suitCards[j];
                            suitCards[j] = suitCards[j + 1];
                            suitCards[j + 1] = temp;
                        }
                    }
                }

                // Take the highest 5 cards
                for (uint8 i = 0; i < 5; i++) {
                    flushCards[i] = suitCards[i];
                }

                // Calculate score with proper ordering (highest to lowest)
                uint256 score = 6 * 10 ** 14;
                score += uint256(flushCards[0]) * 10 ** 8;
                score += uint256(flushCards[1]) * 10 ** 6;
                score += uint256(flushCards[2]) * 10 ** 4;
                score += uint256(flushCards[3]) * 10 ** 2;
                score += uint256(flushCards[4]);

                return (6, score);
            }
        }

        return (0, 0);
    }

    function hasStraight(Card[7] memory cards) internal pure returns (uint8, uint256) {
        // Remove duplicates
        uint8[] memory uniqueRanks = new uint8[](15); // Max 14 ranks + 1 for Ace as 1
        uint8 uniqueCount = 0;

        for (uint8 i = 0; i < 7; i++) {
            bool isDuplicate = false;
            for (uint8 j = 0; j < uniqueCount; j++) {
                if (uniqueRanks[j] == cards[i].rank) {
                    isDuplicate = true;
                    break;
                }
            }

            if (!isDuplicate) {
                uniqueRanks[uniqueCount] = cards[i].rank;
                uniqueCount++;
            }
        }
        // Add Ace as 1 if Ace exists
        bool hasAce = false;
        for (uint8 i = 0; i < uniqueCount; i++) {
            if (uniqueRanks[i] == 14) {
                hasAce = true;
                break;
            }
        }
        if (hasAce) {
            uniqueRanks[uniqueCount] = 1;
            uniqueCount++;
        }

        // Sort ranks
        for (uint8 i = 0; i < uniqueCount - 1; i++) {
            for (uint8 j = 0; j < uniqueCount - i - 1; j++) {
                if (uniqueRanks[j] > uniqueRanks[j + 1]) {
                    uint8 temp = uniqueRanks[j];
                    uniqueRanks[j] = uniqueRanks[j + 1];
                    uniqueRanks[j + 1] = temp;
                }
            }
        }

        // Check for straight
        if (uniqueCount >= 5) {
            for (uint8 i = 0; i <= uniqueCount - 5; i++) {
                if (uniqueRanks[i + 4] == uniqueRanks[i] + 4) {
                    return (5, 5 * 10 ** 14 + uint256(uniqueRanks[i + 4]));
                }
            }
        }
        return (0, 0);
    }

    function hasThreeOfAKind(Card[7] memory cards) internal pure returns (uint8, uint256) {
        uint8[2] memory kickers;

        for (uint256 i = 0; i <= 4; i++) {
            uint8 count = 1;
            uint8 rank = cards[i].rank;

            for (uint256 j = i + 1; j < 7; j++) {
                if (cards[j].rank == rank) {
                    count++;
                }
            }

            if (count == 3) {
                // Find two highest kickers
                uint8 kickerCount = 0;

                // Start from the highest card and work down
                for (int256 j = 6; j >= 0 && kickerCount < 2; j--) {
                    if (cards[uint256(j)].rank != rank) {
                        kickers[kickerCount] = cards[uint256(j)].rank;
                        kickerCount++;
                    }
                }

                // Make sure we have enough kickers before using them
                // Calculate score with safeguards against overflow
                uint256 score = 4 * 10 ** 14; // Reduced exponent to prevent overflow
                score += uint256(rank) * 10 ** 6;

                if (kickerCount >= 2) {
                    score += uint256(kickers[0]) * 10 ** 4 + uint256(kickers[1]);
                } else if (kickerCount == 1) {
                    score += uint256(kickers[0]) * 10 ** 2;
                }

                return (4, score);
            }
        }

        return (0, 0);
    }

    function hasTwoPair(Card[7] memory cards) internal pure returns (uint8, uint256) {
        uint8 highPairRank = 0;
        uint8 lowPairRank = 0;
        // emit PHE_Log(uintToString(cards[6].rank));
        // emit PHE_Log(uintToString(cards[5].rank));
        // emit PHE_Log(uintToString(cards[4].rank));
        // emit PHE_Log(uintToString(cards[3].rank));
        // emit PHE_Log(uintToString(cards[2].rank));
        // emit PHE_Log(uintToString(cards[1].rank));
        // emit PHE_Log(uintToString(cards[0].rank));
        // Find pairs
        for (uint256 i = 6; i > 0; i--) {
            if (cards[i].rank == cards[i - 1].rank) {
                if (highPairRank == 0) {
                    highPairRank = cards[i].rank;
                    // if (i == 1) {
                    //     break;
                    // }
                    // underflow if we subtract 1 from i twice when i == 1
                    if (i > 1) {
                        i--; // Skip the second card of the pair
                    }
                } else {
                    lowPairRank = cards[i].rank;
                    break;
                }
            }
        }
        if (highPairRank > 0 && lowPairRank > 0) {
            // Find highest kicker
            uint8 kicker = 0;

            for (int256 i = 6; i >= 0; i--) {
                if (cards[uint256(i)].rank != highPairRank && cards[uint256(i)].rank != lowPairRank)
                {
                    kicker = cards[uint256(i)].rank;
                    break;
                }
            }
            // Reduced exponent to prevent overflow
            uint256 score = 3 * 10 ** 14;
            score += uint256(highPairRank) * 10 ** 6;
            score += uint256(lowPairRank) * 10 ** 4;
            score += uint256(kicker);

            return (3, score);
        }

        return (0, 0);
    }

    function hasPair(Card[7] memory cards) internal pure returns (uint8, uint256) {
        uint8[3] memory kickers;
        uint8 pairRank = 0;

        // Find pair
        for (uint256 i = 6; i > 0; i--) {
            if (cards[i].rank == cards[i - 1].rank) {
                pairRank = cards[i].rank;
                break;
            }
        }

        if (pairRank > 0) {
            // Find three highest kickers
            uint8 kickerCount = 0;

            for (int256 i = 6; i >= 0 && kickerCount < 3; i--) {
                if (cards[uint256(i)].rank != pairRank) {
                    kickers[kickerCount] = cards[uint256(i)].rank;
                    kickerCount++;
                }
            }

            return (
                2,
                2 * 10 ** 14 + uint256(pairRank) * 10 ** 6 + uint256(kickers[2]) * 10 ** 4
                    + uint256(kickers[1]) * 10 ** 2 + uint256(kickers[0])
            );
        }

        return (0, 0);
    }

    function hasHighCard(Card[7] memory cards) internal pure returns (uint8, uint256) {
        uint256 score = 1 * 10 ** 14;

        // Cards are already sorted by rank, so we take the 5 highest cards
        // Starting from the highest card (index 6) down to the 5th highest (index 2)
        score += uint256(cards[6].rank) * 10 ** 6;
        score += uint256(cards[5].rank) * 10 ** 4;
        score += uint256(cards[4].rank) * 10 ** 3;
        score += uint256(cards[3].rank) * 10 ** 2;
        score += uint256(cards[2].rank);

        return (1, score);
    }

    // string equality check
    function strEq(string memory a, string memory b) public pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
}
