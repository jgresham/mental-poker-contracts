// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

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

    function evaluateHand(Card[2] memory holeCards, Card[5] memory communityCards) public pure returns (Hand memory) {
        Card[7] memory allCards;
        allCards[0] = holeCards[0];
        allCards[1] = holeCards[1];
        for (uint256 i = 0; i < 5; i++) {
            allCards[i + 2] = communityCards[i];
        }

        return findBestHand(allCards);
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
        (bool hasFullHouse, uint8 threeRank, uint8 pairRank) = hasFullHouseWithRanks(cards);
        if (hasFullHouse) {
            bestHand.rank = HandRank.FullHouse;
            bestHand.score = 7 * 10 ** 14 + threeRank * 10 ** 2 + pairRank;
            return bestHand;
        }

        // Continue with other hand rankings...
        // The actual implementation would include all hand rankings
        // For brevity, we're showing the pattern for the top hands

        // Default to high card if no other hand is found
        bestHand.rank = HandRank.HighCard;
        bestHand.score = calculateHighCardScore(cards);
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
