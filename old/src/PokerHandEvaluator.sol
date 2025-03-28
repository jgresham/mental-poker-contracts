// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract PokerHandEvaluator {
    enum HandRank {
        HighCard,
        Pair,
        TwoPair,
        ThreeOfAKind,
        Straight,
        Flush,
        FullHouse,
        FourOfAKind,
        StraightFlush,
        RoyalFlush
    }

    struct Card {
        uint8 rank; // 2-14 (14 = Ace)
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
        uint8 cardNum = uint8(parseInt(cardStr));
        require(cardNum < 52, "Invalid card number");

        uint8 suit = cardNum / 13;
        uint8 rank = cardNum % 13 + 2; // Add 2 because ranks start at 2

        return Card({rank: rank, suit: suit});
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

    function evaluateHand(Card[2] memory holeCards, Card[5] memory communityCards) public pure returns (Hand memory) {
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

    function findBestHand(Card[7] memory cards) internal pure returns (Hand memory) {
        // Sort cards by rank
        for (uint256 i = 0; i < cards.length - 1; i++) {
            for (uint256 j = 0; j < cards.length - i - 1; j++) {
                if (cards[j].rank > cards[j + 1].rank) {
                    Card memory temp = cards[j];
                    cards[j] = cards[j + 1];
                    cards[j + 1] = temp;
                }
            }
        }

        // Check for each hand type from highest to lowest
        Hand memory bestHand;
        uint256 score = 0;
        uint8 rank = 0;

        // Check Royal Flush
        if (hasRoyalFlush(cards)) {
            bestHand.rank = HandRank.RoyalFlush;
            bestHand.score = 10 * 10 ** 14;
            return bestHand;
        }

        // Check Straight Flush
        (bool hasStraightFlush, uint8 highCard) = hasStraightFlushWithHighCard(cards);
        if (hasStraightFlush) {
            bestHand.rank = HandRank.StraightFlush;
            bestHand.score = 9 * 10 ** 14 + highCard;
            return bestHand;
        }

        // Check Four of a Kind
        (bool hasFourOfKind, uint8 fourRank, uint8 kicker) = hasFourOfAKindWithKicker(cards);
        if (hasFourOfKind) {
            bestHand.rank = HandRank.FourOfAKind;
            bestHand.score = 8 * 10 ** 14 + fourRank * 10 ** 2 + kicker;
            return bestHand;
        }

        // Check Full House
        (bool hasFullHouse, uint8 threeRank, uint8 fhPairRank) = hasFullHouseWithRanks(cards);
        if (hasFullHouse) {
            bestHand.rank = HandRank.FullHouse;
            bestHand.score = 7 * 10 ** 14 + threeRank * 10 ** 2 + fhPairRank;
            return bestHand;
        }

        // Check Flush
        (bool hasFlush, uint8[5] memory flushCards) = hasFlushWithCards(cards);
        if (hasFlush) {
            bestHand.rank = HandRank.Flush;
            bestHand.score = 6 * 10 ** 14 + flushCards[4] * 10 ** 8 + flushCards[3] * 10 ** 6 + flushCards[2] * 10 ** 4
                + flushCards[1] * 10 ** 2 + flushCards[0];
            return bestHand;
        }

        // Check Straight
        (bool hasStraight, uint8 straightHighCard) = hasStraightWithHighCard(cards);
        if (hasStraight) {
            bestHand.rank = HandRank.Straight;
            bestHand.score = 5 * 10 ** 14 + straightHighCard;
            return bestHand;
        }

        // Check Three of a Kind
        (bool hasThreeOfKind, uint8 threeOfKindRank, uint8[2] memory threeKickers) = hasThreeOfAKindWithKickers(cards);
        if (hasThreeOfKind) {
            bestHand.rank = HandRank.ThreeOfAKind;
            bestHand.score = 4 * 10 ** 14 + threeOfKindRank * 10 ** 4 + threeKickers[1] * 10 ** 2 + threeKickers[0];
            return bestHand;
        }

        // Check Two Pair
        (bool hasTwoPair, uint8 highPairRank, uint8 lowPairRank, uint8 twoPairKicker) = hasTwoPairWithKicker(cards);
        if (hasTwoPair) {
            bestHand.rank = HandRank.TwoPair;
            bestHand.score = 3 * 10 ** 14 + highPairRank * 10 ** 4 + lowPairRank * 10 ** 2 + twoPairKicker;
            return bestHand;
        }

        // Check Pair
        (bool hasPair, uint8 pairRank, uint8[3] memory pairKickers) = hasPairWithKickers(cards);
        if (hasPair) {
            bestHand.rank = HandRank.Pair;
            bestHand.score =
                2 * 10 ** 14 + pairRank * 10 ** 6 + pairKickers[2] * 10 ** 4 + pairKickers[1] * 10 ** 2 + pairKickers[0];
            return bestHand;
        }

        // Default to high card if no other hand is found
        bestHand.rank = HandRank.HighCard;
        bestHand.score = 1 * 10 ** 14 + calculateHighCardScore(cards);
        return bestHand;
    }

    function hasRoyalFlush(Card[7] memory cards) internal pure returns (bool) {
        for (uint8 suit = 0; suit < 4; suit++) {
            bool hasAce = false;
            bool hasKing = false;
            bool hasQueen = false;
            bool hasJack = false;
            bool hasTen = false;

            for (uint256 i = 0; i < 7; i++) {
                if (cards[i].suit == suit) {
                    if (cards[i].rank == 14) hasAce = true;
                    if (cards[i].rank == 13) hasKing = true;
                    if (cards[i].rank == 12) hasQueen = true;
                    if (cards[i].rank == 11) hasJack = true;
                    if (cards[i].rank == 10) hasTen = true;
                }
            }

            if (hasAce && hasKing && hasQueen && hasJack && hasTen) {
                return true;
            }
        }
        return false;
    }

    function hasStraightFlushWithHighCard(Card[7] memory cards) internal pure returns (bool, uint8) {
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
                for (uint256 i = 0; i < suitCount - 1; i++) {
                    for (uint256 j = 0; j < suitCount - i - 1; j++) {
                        if (suitCards[j] > suitCards[j + 1]) {
                            uint8 temp = suitCards[j];
                            suitCards[j] = suitCards[j + 1];
                            suitCards[j + 1] = temp;
                        }
                    }
                }

                // Check for straight in suited cards
                for (uint256 i = 0; i <= suitCount - 5; i++) {
                    if (suitCards[i + 4] == suitCards[i] + 4) {
                        return (true, suitCards[i + 4]);
                    }
                }
            }
        }
        return (false, 0);
    }

    function hasFourOfAKindWithKicker(Card[7] memory cards) internal pure returns (bool, uint8, uint8) {
        for (uint256 i = 0; i <= 3; i++) {
            uint8 count = 1;
            uint8 rank = cards[i].rank;

            for (uint256 j = i + 1; j < 7; j++) {
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
                return (true, rank, kicker);
            }
        }
        return (false, 0, 0);
    }

    function hasFullHouseWithRanks(Card[7] memory cards) internal pure returns (bool, uint8, uint8) {
        uint8 threeOfAKindRank = 0;
        uint8 pairRank = 0;

        // Find three of a kind
        for (uint256 i = 0; i <= 4; i++) {
            uint8 count = 1;
            uint8 rank = cards[i].rank;

            for (uint256 j = i + 1; j < 7; j++) {
                if (cards[j].rank == rank) {
                    count++;
                }
            }

            if (count >= 3) {
                threeOfAKindRank = rank;
                break;
            }
        }

        if (threeOfAKindRank == 0) {
            return (false, 0, 0);
        }

        // Find pair (different from three of a kind)
        for (uint256 i = 0; i <= 5; i++) {
            if (cards[i].rank != threeOfAKindRank) {
                uint8 count = 1;
                uint8 rank = cards[i].rank;

                for (uint256 j = i + 1; j < 7; j++) {
                    if (cards[j].rank == rank) {
                        count++;
                    }
                }

                if (count >= 2) {
                    pairRank = rank;
                    break;
                }
            }
        }

        return (pairRank > 0, threeOfAKindRank, pairRank);
    }

    function hasFlushWithCards(Card[7] memory cards) internal pure returns (bool, uint8[5] memory) {
        uint8[5] memory flushCards;

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
                // Sort suit cards in descending order
                for (uint256 i = 0; i < suitCount - 1; i++) {
                    for (uint256 j = 0; j < suitCount - i - 1; j++) {
                        if (suitCards[j] < suitCards[j + 1]) {
                            uint8 temp = suitCards[j];
                            suitCards[j] = suitCards[j + 1];
                            suitCards[j + 1] = temp;
                        }
                    }
                }

                // Take the highest 5 cards
                for (uint8 i = 0; i < 5; i++) {
                    flushCards[4 - i] = suitCards[i];
                }

                return (true, flushCards);
            }
        }

        return (false, flushCards);
    }

    function hasStraightWithHighCard(Card[7] memory cards) internal pure returns (bool, uint8) {
        // Remove duplicates
        uint8[] memory uniqueRanks = new uint8[](15); // Max 14 ranks + 1 for Ace as 1
        uint8 uniqueCount = 0;

        for (uint256 i = 0; i < 7; i++) {
            bool isDuplicate = false;
            for (uint256 j = 0; j < uniqueCount; j++) {
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
        for (uint256 i = 0; i < uniqueCount; i++) {
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
        for (uint256 i = 0; i < uniqueCount - 1; i++) {
            for (uint256 j = 0; j < uniqueCount - i - 1; j++) {
                if (uniqueRanks[j] > uniqueRanks[j + 1]) {
                    uint8 temp = uniqueRanks[j];
                    uniqueRanks[j] = uniqueRanks[j + 1];
                    uniqueRanks[j + 1] = temp;
                }
            }
        }

        // Check for straight
        for (uint256 i = 0; i <= uniqueCount - 5; i++) {
            if (uniqueRanks[i + 4] == uniqueRanks[i] + 4) {
                return (true, uniqueRanks[i + 4]);
            }
        }

        return (false, 0);
    }

    function hasThreeOfAKindWithKickers(Card[7] memory cards) internal pure returns (bool, uint8, uint8[2] memory) {
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

                for (int256 j = 6; j >= 0 && kickerCount < 2; j--) {
                    if (cards[uint256(j)].rank != rank) {
                        kickers[kickerCount] = cards[uint256(j)].rank;
                        kickerCount++;
                    }
                }

                return (true, rank, kickers);
            }
        }

        return (false, 0, kickers);
    }

    function hasTwoPairWithKicker(Card[7] memory cards) internal pure returns (bool, uint8, uint8, uint8) {
        uint8 highPairRank = 0;
        uint8 lowPairRank = 0;

        // Find pairs
        for (uint256 i = 6; i > 0; i--) {
            if (cards[i].rank == cards[i - 1].rank) {
                if (highPairRank == 0) {
                    highPairRank = cards[i].rank;
                    i--; // Skip the second card of the pair
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
                if (cards[uint256(i)].rank != highPairRank && cards[uint256(i)].rank != lowPairRank) {
                    kicker = cards[uint256(i)].rank;
                    break;
                }
            }

            return (true, highPairRank, lowPairRank, kicker);
        }

        return (false, 0, 0, 0);
    }

    function hasPairWithKickers(Card[7] memory cards) internal pure returns (bool, uint8, uint8[3] memory) {
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

            return (true, pairRank, kickers);
        }

        return (false, 0, kickers);
    }

    function calculateHighCardScore(Card[7] memory cards) internal pure returns (uint256) {
        uint256 score = 0;
        uint8[5] memory topFive;
        uint8 count = 0;

        // Get top 5 cards
        for (uint256 i = 6; i >= 0 && count < 5; i--) {
            topFive[count] = cards[i].rank;
            count++;
        }

        // Calculate score
        for (uint256 i = 0; i < 5; i++) {
            score += uint256(topFive[i]) * 10 ** (8 - i * 2);
        }

        return score;
    }
}
