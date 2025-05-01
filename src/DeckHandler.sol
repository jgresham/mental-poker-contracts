// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./BigNumbers/BigNumbers.sol";
import "./CryptoUtils.sol";
import "./TexasHoldemRoom.sol";
import "./PokerHandEvaluatorv2.sol";

contract DeckHandler {
    using BigNumbers for BigNumber;

    BigNumber[] public encryptedDeck;
    string[5] public communityCards;

    CryptoUtils public cryptoUtils;
    TexasHoldemRoom public texasHoldemRoom;
    PokerHandEvaluatorv2 public handEvaluator;

    event EncryptedShuffleSubmitted(address indexed player, bytes[] encryptedShuffle);
    event DecryptionValuesSubmitted(
        address indexed player, uint8[] cardIndexes, bytes[] decryptionValues
    );
    event FlopRevealed(address indexed player, string card1, string card2, string card3);
    event TurnRevealed(address indexed player, string card1);
    event RiverRevealed(address indexed player, string card1);
    event PlayerRevealingCards(
        address indexed player, bytes c1, bytes privateKey, bytes c1InversePowPrivateKey
    );
    event PlayerCardsRevealed(
        address indexed player,
        string card1,
        string card2,
        PokerHandEvaluatorv2.HandRank rank,
        uint256 handScore
    );
    event THP_Log(string message);

    constructor(address _texasHoldemRoom, address _cryptoUtils, address _handEvaluator) {
        texasHoldemRoom = TexasHoldemRoom(_texasHoldemRoom);
        cryptoUtils = CryptoUtils(_cryptoUtils);
        handEvaluator = PokerHandEvaluatorv2(_handEvaluator);
        for (uint256 i = 0; i < 52; i++) {
            encryptedDeck.push(BigNumber({ val: "0", neg: false, bitlen: 2048 }));
        }
    }

    // called when a new round starts, only callable by the room contract
    function resetDeck() external {
        require(msg.sender == address(texasHoldemRoom), "Only the room contract can reset the deck");
        for (uint8 i = 0; i < 52; i++) {
            encryptedDeck[i] = BigNumber({ val: "0", neg: false, bitlen: 2048 });
        }
        communityCards = ["", "", "", "", ""];
    }

    function submitEncryptedShuffle(bytes[] memory encryptedShuffle) external {
        require(encryptedShuffle.length == 52, "Must provide exactly 52 cards");
        require(texasHoldemRoom.stage() == TexasHoldemRoom.GameStage.Shuffle, "Wrong stage");
        uint8 playerIndex = texasHoldemRoom.getPlayerIndexFromAddr(msg.sender);
        uint8 currentPlayerIndex = texasHoldemRoom.currentPlayerIndex();
        require(currentPlayerIndex == playerIndex, "Not your turn to shuffle");

        // Store shuffle as an action?
        emit EncryptedShuffleSubmitted(msg.sender, encryptedShuffle);

        // Copy each element individually since direct array assignment is not supported
        for (uint8 i = 0; i < encryptedShuffle.length; i++) {
            encryptedDeck[i] = BigNumbers.init(encryptedShuffle[i], false);
        }
        texasHoldemRoom.progressGame();
    }

    // fully new function
    function submitDecryptionValues(uint8[] memory cardIndexes, bytes[] memory decryptionValues)
        external
    {
        TexasHoldemRoom.GameStage stage = texasHoldemRoom.stage();
        require(
            stage == TexasHoldemRoom.GameStage.RevealDeal
                || stage == TexasHoldemRoom.GameStage.RevealFlop
                || stage == TexasHoldemRoom.GameStage.RevealTurn
                || stage == TexasHoldemRoom.GameStage.RevealRiver,
            "Game is not in a reveal stage"
        );
        uint8 playerIndex = texasHoldemRoom.getPlayerIndexFromAddr(msg.sender);
        uint8 currentPlayerIndex = texasHoldemRoom.currentPlayerIndex();
        require(currentPlayerIndex == playerIndex, "Not your turn to decrypt");
        require(
            cardIndexes.length == decryptionValues.length,
            "Mismatch in cardIndexes and decryptionValues lengths"
        );
        // TODO: verify decryption values?
        // TODO: verify decryption indexes
        emit DecryptionValuesSubmitted(msg.sender, cardIndexes, decryptionValues);

        for (uint8 i = 0; i < cardIndexes.length; i++) {
            encryptedDeck[cardIndexes[i]] = BigNumbers.init(decryptionValues[i], false);
        }

        // The dealer always starts decrypting, so when we are back at the dealer,
        // we know the last player has decrypted community cards, so emit/set the community cards
        uint8 nextRevealPlayer = texasHoldemRoom.getNextActivePlayer(true);
        if (nextRevealPlayer == texasHoldemRoom.dealerPosition()) {
            if (stage == TexasHoldemRoom.GameStage.RevealFlop) {
                // convert the decrypted cards to a string
                string memory card1 = cryptoUtils.decodeBigintMessage(encryptedDeck[5]);
                string memory card2 = cryptoUtils.decodeBigintMessage(encryptedDeck[6]);
                string memory card3 = cryptoUtils.decodeBigintMessage(encryptedDeck[7]);
                emit FlopRevealed(msg.sender, card1, card2, card3);
                communityCards[0] = card1;
                communityCards[1] = card2;
                communityCards[2] = card3;
            } else if (stage == TexasHoldemRoom.GameStage.RevealTurn) {
                // convert the decrypted cards to a string
                string memory card1 = cryptoUtils.decodeBigintMessage(encryptedDeck[9]);
                emit TurnRevealed(msg.sender, card1);
                communityCards[3] = card1;
            } else if (stage == TexasHoldemRoom.GameStage.RevealRiver) {
                // convert the decrypted cards to a string
                string memory card1 = cryptoUtils.decodeBigintMessage(encryptedDeck[11]);
                emit RiverRevealed(msg.sender, card1);
                communityCards[4] = card1;
            }
        }

        texasHoldemRoom.progressGame();
    }

    /**
     * @dev Reveals the player's cards.
     * @dev Many todos: validate the encrypted cards, the card indexes for the player are valid (getCardIndexForPlayer in js),
     * @dev and that it is appropriate (showdown/all-in) to reveal cards.
     * @param c1 The player's encryption key c1 (derived from the private key)
     * @param privateKey The player's private key
     * @param c1InversePowPrivateKey The inverse of the player's c1*privateKey modulo inverse for decryption
     */
    function revealMyCards(
        bytes memory c1,
        bytes memory privateKey,
        bytes memory c1InversePowPrivateKey
    ) external returns (string memory card1, string memory card2) {
        uint8 playerIndex = texasHoldemRoom.getPlayerIndexFromAddr(msg.sender);
        TexasHoldemRoom.Player memory player = texasHoldemRoom.getPlayer(playerIndex);
        // todo: uncomment this
        require(!player.joinedAndWaitingForNextRound, "Player not joined after round started");
        require(!player.hasFolded, "Player folded");
        require(
            cryptoUtils.strEq(player.cards[0], ""),
            "Player already revealed cards (0) in this round"
        );
        require(
            cryptoUtils.strEq(player.cards[1], ""),
            "Player already revealed cards (1) in this round"
        );
        emit PlayerRevealingCards(msg.sender, c1, privateKey, c1InversePowPrivateKey);
        // scope block to reduce number of variables in memory (evm stack depth limited to 16 variables)
        {
            uint8[2] memory playerCardIndexes = texasHoldemRoom.getPlayersCardIndexes(playerIndex);
            BigNumber memory privateKeyBN = BigNumbers.init(privateKey, false, 2048);
            BigNumber memory c1BN = BigNumbers.init(c1, false, 2048);
            BigNumber memory encryptedCard1BN = encryptedDeck[playerCardIndexes[0]];
            BigNumber memory encryptedCard2BN = encryptedDeck[playerCardIndexes[1]];
            CryptoUtils.EncryptedCard memory encryptedCard1Struct =
                CryptoUtils.EncryptedCard({ c1: c1BN, c2: encryptedCard1BN });
            CryptoUtils.EncryptedCard memory encryptedCard2Struct =
                CryptoUtils.EncryptedCard({ c1: c1BN, c2: encryptedCard2BN });
            BigNumber memory c1InversePowPrivateKeyBN =
                BigNumbers.init(c1InversePowPrivateKey, false, 2048);
            BigNumber memory decryptedCard1 = cryptoUtils.verifyDecryptCard(
                encryptedCard1Struct, privateKeyBN, c1InversePowPrivateKeyBN
            );
            BigNumber memory decryptedCard2 = cryptoUtils.verifyDecryptCard(
                encryptedCard2Struct, privateKeyBN, c1InversePowPrivateKeyBN
            );

            // convert the decrypted cards to a string
            card1 = cryptoUtils.decodeBigintMessage(decryptedCard1);
            card2 = cryptoUtils.decodeBigintMessage(decryptedCard2);
        }
        player.cards[0] = card1;
        player.cards[1] = card2;

        // Get the player's hand score (using player's cards and community cards) from HandEvaluator
        // Combine player cards and community cards into a single array
        string[7] memory allCards;
        allCards[0] = card1;
        allCards[1] = card2;
        allCards[2] = communityCards[0];
        allCards[3] = communityCards[1];
        allCards[4] = communityCards[2];
        allCards[5] = communityCards[3];
        allCards[6] = communityCards[4];
        PokerHandEvaluatorv2.Hand memory playerHand = handEvaluator.findBestHandExternal(allCards);
        uint256 playerHandScore = playerHand.score;
        texasHoldemRoom.setPlayerHandScore(playerIndex, playerHandScore);

        emit PlayerCardsRevealed(
            address(msg.sender), card1, card2, playerHand.rank, playerHandScore
        );
        emit THP_Log("emit PlayerCardsRevealed() in revealMyCards()");
        // return true if the encrypted cards match the decrypted cards from the deck?
        texasHoldemRoom.progressGame();
        emit THP_Log("after texasHoldemRoom.progressGame()");
        return (card1, card2);
    }

    function getEncryptedDeck() external view returns (bytes[] memory) {
        bytes[] memory deckBytes = new bytes[](encryptedDeck.length);
        for (uint8 i = 0; i < encryptedDeck.length; i++) {
            deckBytes[i] = encryptedDeck[i].val;
        }
        return deckBytes;
    }

    function getEncrypedCard(uint256 cardIndex) external view returns (BigNumber memory) {
        return encryptedDeck[cardIndex];
    }

    function getCommunityCards() external view returns (string[5] memory) {
        return communityCards;
    }

    /**
     * @dev Returns all simple public variables of the TexasHoldemRoom contract and the encrypted deck
     * To reduce the size of the TexasHoldemRoom contract, this function is put here.
     */
    struct BulkRoomData {
        uint256 roundNumber;
        TexasHoldemRoom.GameStage stage;
        uint256 smallBlind;
        uint256 bigBlind;
        uint8 dealerPosition;
        uint8 currentPlayerIndex;
        uint8 lastRaiseIndex;
        uint256 pot;
        uint256 currentStageBet;
        uint8 numPlayers;
        bool isPrivate;
        string[5] communityCards;
        bytes[] encryptedDeck;
    }

    function getBulkRoomData() external view returns (BulkRoomData memory) {
        return BulkRoomData({
            roundNumber: texasHoldemRoom.roundNumber(),
            stage: texasHoldemRoom.stage(),
            smallBlind: texasHoldemRoom.smallBlind(),
            bigBlind: texasHoldemRoom.bigBlind(),
            dealerPosition: texasHoldemRoom.dealerPosition(),
            currentPlayerIndex: texasHoldemRoom.currentPlayerIndex(),
            lastRaiseIndex: texasHoldemRoom.lastRaiseIndex(),
            pot: texasHoldemRoom.pot(),
            currentStageBet: texasHoldemRoom.currentStageBet(),
            numPlayers: texasHoldemRoom.numPlayers(),
            isPrivate: texasHoldemRoom.isPrivate(),
            encryptedDeck: this.getEncryptedDeck(),
            communityCards: communityCards
        });
    }
}
