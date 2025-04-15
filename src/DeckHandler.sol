// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./BigNumbers/BigNumbers.sol";
import "./CryptoUtils.sol";
import "./TexasHoldemRoom.sol";

contract DeckHandler {
    using BigNumbers for BigNumber;

    BigNumber[] public encryptedDeck;

    CryptoUtils public cryptoUtils;
    TexasHoldemRoom public texasHoldemRoom;

    event EncryptedShuffleSubmitted(address indexed player, bytes[] encryptedShuffle);
    event DecryptionValuesSubmitted(
        address indexed player, uint8[] cardIndexes, bytes[] decryptionValues
    );
    event FlopRevealed(address indexed player, string card1, string card2, string card3);
    event TurnRevealed(address indexed player, string card1);
    event RiverRevealed(address indexed player, string card1);
    // event THP_Log(string message);

    constructor(address _texasHoldemRoom, address _cryptoUtils) {
        texasHoldemRoom = TexasHoldemRoom(_texasHoldemRoom);
        cryptoUtils = CryptoUtils(_cryptoUtils);
        for (uint256 i = 0; i < 52; i++) {
            encryptedDeck.push(BigNumber({ val: "0", neg: false, bitlen: 2048 }));
        }
    }

    // fully new function
    // function submitEncryptedShuffle(BigNumber[] memory encryptedShuffle) external {
    function submitEncryptedShuffle(bytes[] memory encryptedShuffle) external {
        require(encryptedShuffle.length == 52, "Must provide exactly 52 cards");
        require(texasHoldemRoom.stage() == TexasHoldemRoom.GameStage.Shuffle, "Wrong stage");
        uint256 playerIndex = texasHoldemRoom.getPlayerIndexFromAddr(msg.sender);
        uint256 currentPlayerIndex = texasHoldemRoom.currentPlayerIndex();
        require(currentPlayerIndex == playerIndex, "Not your turn to shuffle");

        // Store shuffle as an action?
        emit EncryptedShuffleSubmitted(msg.sender, encryptedShuffle);

        // Copy each element individually since direct array assignment is not supported
        for (uint256 i = 0; i < encryptedShuffle.length; i++) {
            encryptedDeck[i] = BigNumbers.init(encryptedShuffle[i], false);
        }

        currentPlayerIndex = (currentPlayerIndex + 1) % texasHoldemRoom.numPlayers();
        texasHoldemRoom.setCurrentPlayerIndex(currentPlayerIndex);
        // if we are back at the dealer, move to the next stage
        if (currentPlayerIndex == texasHoldemRoom.dealerPosition()) {
            texasHoldemRoom.setStage(TexasHoldemRoom.GameStage.RevealDeal);
        }
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
        uint256 playerIndex = texasHoldemRoom.getPlayerIndexFromAddr(msg.sender);
        uint256 currentPlayerIndex = texasHoldemRoom.currentPlayerIndex();
        require(currentPlayerIndex == playerIndex, "Not your turn to decrypt");
        require(
            cardIndexes.length == decryptionValues.length,
            "Mismatch in cardIndexes and decryptionValues lengths"
        );
        // TODO: verify decryption values?
        // TODO: verify decryption indexes
        emit DecryptionValuesSubmitted(msg.sender, cardIndexes, decryptionValues);

        for (uint256 i = 0; i < cardIndexes.length; i++) {
            encryptedDeck[cardIndexes[i]] = BigNumbers.init(decryptionValues[i], false);
        }

        if (currentPlayerIndex == 1) {
            // todo: it shouldn't be fixed at 1?
            if (stage == TexasHoldemRoom.GameStage.RevealFlop) {
                // convert the decrypted cards to a string
                string memory card1 = cryptoUtils.decodeBigintMessage(encryptedDeck[5]);
                string memory card2 = cryptoUtils.decodeBigintMessage(encryptedDeck[6]);
                string memory card3 = cryptoUtils.decodeBigintMessage(encryptedDeck[7]);
                texasHoldemRoom.setCommunityCards(0, card1);
                texasHoldemRoom.setCommunityCards(1, card2);
                texasHoldemRoom.setCommunityCards(2, card3);
                emit FlopRevealed(msg.sender, card1, card2, card3);
            } else if (stage == TexasHoldemRoom.GameStage.RevealTurn) {
                // convert the decrypted cards to a string
                string memory card1 = cryptoUtils.decodeBigintMessage(encryptedDeck[9]);
                texasHoldemRoom.setCommunityCards(3, card1);
                emit TurnRevealed(msg.sender, card1);
            } else if (stage == TexasHoldemRoom.GameStage.RevealRiver) {
                // convert the decrypted cards to a string
                string memory card1 = cryptoUtils.decodeBigintMessage(encryptedDeck[11]);
                texasHoldemRoom.setCommunityCards(4, card1);
                emit RiverRevealed(msg.sender, card1);
            }
        }

        texasHoldemRoom.progressGame();
    }

    // /**
    //  * @dev Reveals the player's cards.
    //  * @dev Many todos: validate the encrypted cards, the card indexes for the player are valid,
    //  * @dev and that it is appropriate (showdown/all-in) to reveal cards.
    //  * @param encryptedCard1 The player's encrypted card 1
    //  * @param encryptedCard2 The player's encrypted card 2
    //  * @param privateKey The player's private key
    //  * @param c1Inverse The inverse of the player's c1 modulo inverse for decryption
    //  */
    // function revealMyCards(
    //     CryptoUtils.EncryptedCard memory encryptedCard1,
    //     CryptoUtils.EncryptedCard memory encryptedCard2,
    //     BigNumber memory privateKey,
    //     BigNumber memory c1Inverse
    // ) external returns (string memory card1, string memory card2) {
    //     uint256 playerIndex = texasHoldemRoom.getPlayerIndexFromAddr(msg.sender);
    //     require(!players[playerIndex].hasFolded, "Player folded");
    //     require(
    //         cryptoUtils.strEq(players[playerIndex].cards[0], ""),
    //         "Player already revealed cards (0) in this round"
    //     );
    //     require(
    //         cryptoUtils.strEq(players[playerIndex].cards[1], ""),
    //         "Player already revealed cards (1) in this round"
    //     );

    //     // Create an instance of CryptoUtils to call its functions
    //     BigNumber memory decryptedCard1 =
    //         cryptoUtils.verifyDecryptCard(encryptedCard1, privateKey, c1Inverse);
    //     BigNumber memory decryptedCard2 =
    //         cryptoUtils.verifyDecryptCard(encryptedCard2, privateKey, c1Inverse);

    //     // convert the decrypted cards to a string
    //     card1 = cryptoUtils.decodeBigintMessage(decryptedCard1);
    //     card2 = cryptoUtils.decodeBigintMessage(decryptedCard2);
    //     players[playerIndex].cards[0] = card1;
    //     players[playerIndex].cards[1] = card2;

    //     emit PlayerCardsRevealed(address(msg.sender), card1, card2);

    //     // TODO: set the cards on the encryptedDeck?
    //     // return true if the encrypted cards match the decrypted cards from the deck?

    //     // put in progressGame()?
    //     // if (countOfHandsRevealed() == countActivePlayers()) {
    //     //     // decide winner
    //     // }

    //     // // Convert the encrypted cards to bytes32 format for storage
    //     // bytes32[2] memory cardBytes;
    //     // // You would need to implement a conversion function or logic here
    //     // // For example: cardBytes[0] = bytes32(abi.encode(encryptedCard1));
    //     // // cardBytes[1] = bytes32(abi.encode(encryptedCard2));
    //     // players[playerIndex].cards = cardBytes;
    //     return (card1, card2);
    // }

    function getEncryptedDeck() external view returns (bytes[] memory) {
        bytes[] memory deckBytes = new bytes[](encryptedDeck.length);
        for (uint256 i = 0; i < encryptedDeck.length; i++) {
            deckBytes[i] = encryptedDeck[i].val;
        }
        return deckBytes;
    }

    function getEncrypedCard(uint256 cardIndex) external view returns (BigNumber memory) {
        return encryptedDeck[cardIndex];
    }

    /**
     * @dev Returns all simple public variables of the TexasHoldemRoom contract and the encrypted deck
     * To reduce the size of the TexasHoldemRoom contract, this function is put here.
     * @return stage The current game stage
     * @return smallBlind The small blind amount
     * @return bigBlind The big blind amount
     * @return dealerPosition The position of the dealer
     * @return currentPlayerIndex The index of the current player
     * @return lastRaiseIndex The index of the last player who raised
     * @return pot The total pot amount
     * @return currentStageBet The current bet amount for this stage
     * @return numPlayers The number of players in the game
     * @return isPrivate Whether the game is private
     * @return communityCards The community cards revealed so far
     */
    function getPublicVariables()
        external
        view
        returns (
            TexasHoldemRoom.GameStage,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            // string[] memory,
            bytes[] memory
        )
    {
        return (
            texasHoldemRoom.stage(),
            texasHoldemRoom.smallBlind(),
            texasHoldemRoom.bigBlind(),
            texasHoldemRoom.dealerPosition(),
            texasHoldemRoom.currentPlayerIndex(),
            texasHoldemRoom.lastRaiseIndex(),
            texasHoldemRoom.pot(),
            texasHoldemRoom.currentStageBet(),
            texasHoldemRoom.numPlayers(),
            texasHoldemRoom.isPrivate(),
            // texasHoldemRoom.communityCards(),
            this.getEncryptedDeck()
        );
    }
}
