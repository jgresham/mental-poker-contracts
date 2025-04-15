// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import "./PokerHandEvaluatorv2.sol";
import "./BigNumbers/BigNumbers.sol";
import "./CryptoUtils.sol";
import "./DeckHandler.sol";

contract TexasHoldemRoom {
    using BigNumbers for BigNumber;

    enum GameStage {
        Idle, // 0
        Shuffle, // 1
        RevealDeal, // 2
        Preflop, // 3
        RevealFlop, // 4
        Flop, // 5
        RevealTurn, // 6
        Turn, // 7
        RevealRiver, // 8
        River, // 9
        Showdown, // 10
        Break, // 11
        Ended // 12

    }

    enum Action {
        None, // 0
        Call, // 1
        Raise, // 2
        Check, // 3
        Fold // 4

    }

    struct Player {
        address addr;
        uint256 chips;
        uint256 currentStageBet;
        uint256 totalRoundBet;
        bool hasFolded;
        bool isAllIn;
        string[2] cards;
        uint8 seatPosition;
    }

    uint256 public roundNumber;
    GameStage public stage;
    uint256 public pot;
    uint256 public currentStageBet; // per player (to stay in the round)
    uint256 public smallBlind;
    uint256 public bigBlind;
    uint256 public dealerPosition;
    uint256 public currentPlayerIndex;
    uint256 public lastRaiseIndex;
    string[5] public communityCards;

    uint256 public constant MAX_PLAYERS = 10;
    uint256 public constant MIN_PLAYERS = 2;
    uint8 public constant EMPTY_SEAT = 255;
    uint256 public constant STARTING_CHIPS = 1000;

    CryptoUtils public cryptoUtils;
    PokerHandEvaluatorv2 public handEvaluator;
    DeckHandler public deckHandler;

    Player[MAX_PLAYERS] public players;
    uint8[MAX_PLAYERS] public seatPositionToPlayerIndex;
    uint256 public numPlayers;
    bool public isPrivate;

    event GameStarted(uint256 dealerPosition);
    event NewStage(GameStage stage);
    event PlayerMoved(address indexed player, Action indexed action, uint256 amount);
    event PotWon(address indexed winner, uint256 amount);
    event PlayerCardsRevealed(address indexed player, string card1, string card2);
    // event THP_Log(string message);

    constructor(
        address _cryptoUtils,
        address _handEvaluator,
        // address _deckHandler,
        uint256 _smallBlind,
        bool _isPrivate
    ) {
        cryptoUtils = CryptoUtils(_cryptoUtils);
        handEvaluator = PokerHandEvaluatorv2(_handEvaluator);
        // deckHandler = DeckHandler(_deckHandler, address(this), _cryptoUtils);
        smallBlind = _smallBlind;
        bigBlind = _smallBlind * 2;
        stage = GameStage.Idle;
        roundNumber = 0;
        isPrivate = _isPrivate;
        dealerPosition = 0;
        currentPlayerIndex = 0;
        for (uint256 i = 0; i < MAX_PLAYERS; i++) {
            seatPositionToPlayerIndex[i] = EMPTY_SEAT;
        }
    }

    /**
     * @dev Should only be set by the deployer contract. Can only be called once.
     */
    function setDeckHandler(address _deckHandler) external {
        require(address(deckHandler) == address(0), "DeckHandler already set");
        deckHandler = DeckHandler(_deckHandler);
    }

    // fully new function
    function getPlayerIndexFromAddr(address addr) external view returns (uint256) {
        for (uint256 i = 0; i < numPlayers; i++) {
            if (players[i].addr == addr) {
                return i;
            }
        }
        revert("Player not found for given address");
    }

    /**
     * @dev Finds the next active player index to the left of the current player using seat position
     * @dev Skips players that have folded or are all-in
     * @dev Returns the current player index if no active players are found
     */
    function getNextActivePlayer(bool requireActive) public view returns (uint256) {
        // get the current player's seat position
        uint8 currentSeatPosition = players[currentPlayerIndex].seatPosition; // 1, 1
        // loop over the players in the ascending order of their seat positions
        // until we find an active player
        // TODO: create a number of players that played in the current round and use that for the modulo
        // and for the next seat index. (don't use players that joined the game after the round started)
        uint256 nextSeatIndex = (currentSeatPosition + 1) % numPlayers; // 2 % 2 = 0
        if (!requireActive) {
            return seatPositionToPlayerIndex[nextSeatIndex];
        } else {
            while (nextSeatIndex != currentSeatPosition) {
                // TODO: add a status for a player that has joined, but did not start the round
                uint8 playerIndex = seatPositionToPlayerIndex[nextSeatIndex];
                if (playerIndex != EMPTY_SEAT) {
                    Player memory checkPlayer = players[playerIndex];
                    // TODO: check if the player has cards (joined before the round started)
                    if (!checkPlayer.hasFolded && !checkPlayer.isAllIn) {
                        return playerIndex;
                    }
                }
                nextSeatIndex = (nextSeatIndex + 1) % numPlayers;
            }
            // if no active players are found, return the current player
            return currentPlayerIndex;
        }
    }

    // fully new function
    function joinGame() external {
        require(numPlayers < MAX_PLAYERS, "Room is full");
        // Check if player is already in the game
        for (uint256 i = 0; i < numPlayers; i++) {
            if (players[i].addr == msg.sender) {
                revert("Already in game");
            }
        }

        numPlayers++;
        // Find the first empty seat
        uint8 seatPosition = 0;
        while (seatPositionToPlayerIndex[seatPosition] != EMPTY_SEAT) {
            seatPosition++;
        }
        players[numPlayers - 1] = Player({
            addr: msg.sender,
            chips: STARTING_CHIPS,
            currentStageBet: 0,
            totalRoundBet: 0,
            hasFolded: false,
            isAllIn: false,
            cards: ["", ""],
            seatPosition: seatPosition
        });
        seatPositionToPlayerIndex[seatPosition] = uint8(numPlayers - 1);

        if (numPlayers >= MIN_PLAYERS && !isPrivate) {
            _progressGame();
        }
    }

    function startNewHand() external {
        require(numPlayers >= MIN_PLAYERS, "Not enough players");
        require(stage == GameStage.Idle, "Game in progress");

        // Reset game state
        roundNumber++;
        stage = GameStage.Shuffle;
        pot = 0;
        currentStageBet = bigBlind;
        dealerPosition = (dealerPosition + 1) % numPlayers;
        currentPlayerIndex = (dealerPosition + 3) % numPlayers; // Start after BB
        lastRaiseIndex = currentPlayerIndex;

        // Reset player states
        for (uint256 i = 0; i < numPlayers; i++) {
            players[i].currentStageBet = 0;
            players[i].totalRoundBet = 0;
            players[i].hasFolded = false;
            players[i].isAllIn = false;
            players[i].cards = ["", ""];
        }

        // Post blinds
        uint256 sbPosition = (dealerPosition + 1) % numPlayers;
        uint256 bbPosition = (dealerPosition + 2) % numPlayers;

        _placeBet(sbPosition, smallBlind);
        _placeBet(bbPosition, bigBlind);

        emit GameStarted(dealerPosition);
        emit NewStage(GameStage.Preflop);
    }

    // mostly fully tested function
    function submitAction(Action action, uint256 raiseAmount) external {
        require(
            stage == GameStage.Preflop || stage == GameStage.Flop || stage == GameStage.Turn
                || stage == GameStage.River,
            "Game not in a betting stage"
        );
        uint256 playerIndex = this.getPlayerIndexFromAddr(msg.sender);
        require(playerIndex == currentPlayerIndex, "Not your turn");
        require(!players[playerIndex].hasFolded, "Player has folded");
        require(!players[playerIndex].isAllIn, "Player is all-in");

        if (action == Action.Fold) {
            players[playerIndex].hasFolded = true;
        } else if (action == Action.Call) {
            uint256 callAmount = currentStageBet - players[playerIndex].currentStageBet;
            require(players[playerIndex].chips >= callAmount, "Not enough chips");
            _placeBet(playerIndex, callAmount);
        } else if (action == Action.Raise) {
            require(raiseAmount > currentStageBet, "Raise must be higher than current bet");
            uint256 totalAmount = raiseAmount - players[playerIndex].currentStageBet;
            require(players[playerIndex].chips >= totalAmount, "Not enough chips");
            _placeBet(playerIndex, totalAmount);
            currentStageBet = raiseAmount;
            lastRaiseIndex = playerIndex;
        } else if (action == Action.Check) {
            require(players[playerIndex].currentStageBet == currentStageBet, "Must call or raise");
        }

        emit PlayerMoved(msg.sender, action, raiseAmount);

        // Move to next player or stage
        _progressGame();
    }

    /**
     * @dev Reveals the player's cards.
     * @dev Many todos: validate the encrypted cards, the card indexes for the player are valid,
     * @dev and that it is appropriate (showdown/all-in) to reveal cards.
     * @param encryptedCard1 The player's encrypted card 1
     * @param encryptedCard2 The player's encrypted card 2
     * @param privateKey The player's private key
     * @param c1Inverse The inverse of the player's c1 modulo inverse for decryption
     */
    function revealMyCards(
        CryptoUtils.EncryptedCard memory encryptedCard1,
        CryptoUtils.EncryptedCard memory encryptedCard2,
        BigNumber memory privateKey,
        BigNumber memory c1Inverse
    ) external returns (string memory card1, string memory card2) {
        uint256 playerIndex = this.getPlayerIndexFromAddr(msg.sender);
        require(!players[playerIndex].hasFolded, "Player folded");
        require(
            cryptoUtils.strEq(players[playerIndex].cards[0], ""),
            "Player already revealed cards (0) in this round"
        );
        require(
            cryptoUtils.strEq(players[playerIndex].cards[1], ""),
            "Player already revealed cards (1) in this round"
        );

        // Create an instance of CryptoUtils to call its functions
        BigNumber memory decryptedCard1 =
            cryptoUtils.verifyDecryptCard(encryptedCard1, privateKey, c1Inverse);
        BigNumber memory decryptedCard2 =
            cryptoUtils.verifyDecryptCard(encryptedCard2, privateKey, c1Inverse);

        // convert the decrypted cards to a string
        card1 = cryptoUtils.decodeBigintMessage(decryptedCard1);
        card2 = cryptoUtils.decodeBigintMessage(decryptedCard2);
        players[playerIndex].cards[0] = card1;
        players[playerIndex].cards[1] = card2;

        emit PlayerCardsRevealed(address(msg.sender), card1, card2);

        // TODO: set the cards on the encryptedDeck?
        // return true if the encrypted cards match the decrypted cards from the deck?

        // put in progressGame()?
        // if (countOfHandsRevealed() == countActivePlayers()) {
        //     // decide winner
        // }

        // // Convert the encrypted cards to bytes32 format for storage
        // bytes32[2] memory cardBytes;
        // // You would need to implement a conversion function or logic here
        // // For example: cardBytes[0] = bytes32(abi.encode(encryptedCard1));
        // // cardBytes[1] = bytes32(abi.encode(encryptedCard2));
        // players[playerIndex].cards = cardBytes;
        return (card1, card2);
    }

    // function determineWinners() external {
    //     require(stage == GameStage.Showdown, "Not showdown stage");

    //     address[] memory activePlayers = new address[](numPlayers);
    //     uint256 activeCount = 0;

    //     // Get active players who revealed their hands
    //     for (uint256 i = 0; i < numPlayers; i++) {
    //         address playerAddr = players[i].addr;
    //         if (!players[i].hasFolded && revealedCards[playerAddr][0].rank != 0) {
    //             activePlayers[activeCount] = playerAddr;
    //             activeCount++;
    //         }
    //     }

    //     require(activeCount > 0, "No hands revealed");

    //     // Convert community cards from bytes32 to Card struct
    //     PokerHandEvaluatorv2.Card[5] memory communityCards;
    //     for (uint256 i = 0; i < 5; i++) {
    //         // In a real implementation, you would decode the bytes32 into rank and suit
    //         // This is a placeholder for the actual decoding logic
    //         (uint8 rank, uint8 suit) = (0, 0); // todo fix
    //         communityCards[i] = PokerHandEvaluatorv2.Card({rank: rank, suit: suit});
    //     }

    //     // Evaluate hands and find winners
    //     uint256 highestScore = 0;
    //     address[] memory winners = new address[](activeCount);
    //     uint256 winnerCount = 0;

    //     for (uint256 i = 0; i < activeCount; i++) {
    //         address playerAddr = activePlayers[i];
    //         PokerHandEvaluatorv2.Hand memory hand =
    //             handEvaluator.evaluateHand(revealedCards[playerAddr], communityCards);

    //         if (hand.score > highestScore) {
    //             // New highest hand
    //             highestScore = hand.score;
    //             winners[0] = playerAddr;
    //             winnerCount = 1;
    //         } else if (hand.score == highestScore) {
    //             // Tie
    //             winners[winnerCount] = playerAddr;
    //             winnerCount++;
    //         }
    //     }

    //     // Distribute pot
    //     uint256 winAmount = pot / winnerCount;
    //     for (uint256 i = 0; i < winnerCount; i++) {
    //         address winner = winners[i];
    //         uint256 winnerIndex = getPlayerIndexFromAddr(winner);
    //         if (winnerIndex >= 0) {
    //             players[winnerIndex].chips += winAmount;
    //         } else {
    //             // TODO: Handle case where winner is not in the game?
    //         }
    //         emit PotWon(winner, winAmount);
    //     }

    //     // Reset game state
    //     stage = GameStage.Idle;
    //     pot = 0;

    //     // Clear revealed cards and commitments
    //     for (uint256 i = 0; i < numPlayers; i++) {
    //         address playerAddr = players[i].addr;
    //         delete revealedCards[playerAddr];
    //         delete commitments[playerAddr];
    //         delete secrets[playerAddr];
    //     }
    // }

    function _placeBet(uint256 playerIndex, uint256 amount) internal {
        require(players[playerIndex].chips >= amount, "Not enough chips");
        players[playerIndex].chips -= amount;
        players[playerIndex].currentStageBet += amount;
        players[playerIndex].totalRoundBet += amount;
        pot += amount;

        if (players[playerIndex].chips == 0) {
            players[playerIndex].isAllIn = true;
        }
    }

    function _endRound() internal {
        // TODO: handle a new round of poker after showdown or only 1 active players
        // give the last active player the pot
        // reset the game state
        // reset the players's statuses, cards, etc,
        // start a new round
        // move dealer position to the left (and blinds later on)
    }

    function progressGame() external {
        require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
        _progressGame();
    }

    /**
     * @dev Increments the current player index and moves to the next stage
     * @dev If in a reveal stage, all players need to submit their decryption values
     * @dev If in a betting stage, only the players who are not all-in
     * @dev and not folded need to submit their actions
     * @notice Emits a NewStage event and new current player index event
     */
    function _progressGame() internal {
        if (stage == GameStage.Idle) {
            return _moveToNextStage();
        }

        // shuffle or reveal stage
        if (
            stage == GameStage.Shuffle || stage == GameStage.RevealDeal
                || stage == GameStage.RevealFlop || stage == GameStage.RevealTurn
                || stage == GameStage.RevealRiver
        ) {
            // emit THP_Log("_progressGame() if Reveal stage true");
            // if the next reveal player is back at the dealer, move to the next stage
            // since the dealer starts all reveal stages
            bool requireActive = false;
            uint256 nextRevealPlayer = getNextActivePlayer(requireActive);
            if (nextRevealPlayer == dealerPosition) {
                // emit THP_Log("_progressGame() if nextRevealPlayer == dealerPosition");
                // after a reveal stage, we enter a betting stage
                // always the first active player LEFT of the dealer starts all betting stages
                bool requireActiveForBetting = true;
                currentPlayerIndex = dealerPosition;
                uint256 nextActivePlayer = getNextActivePlayer(requireActiveForBetting);
                currentPlayerIndex = nextActivePlayer;
                // at the start of a betting stage, the last raise index is the first active player by default
                lastRaiseIndex = nextActivePlayer;
                return _moveToNextStage();
            } else {
                // otherwise, the next player should submit their decryption values
                currentPlayerIndex = nextRevealPlayer;
            }
        } else {
            // current in a betting stage or showdown stage

            // if there are no more active players, the round ends and the last
            // active player wins the pot
            if (countActivePlayers() == 1) {
                _endRound();
                // emit THP_Log("_progressGame() if _countActivePlayers() == 1");
            }

            // if the last raise index is the same as the next active player index,
            // the betting stage is complete.
            // Reset the round bet amounts and move to the next stage
            bool requireActive = true;
            uint256 nextPlayer = getNextActivePlayer(requireActive);
            // Check if betting round is complete
            if (nextPlayer == lastRaiseIndex) {
                // emit THP_Log("_progressGame() if nextPlayer == lastRaiseIndex");
                // Reset betting for a new betting stage
                // do not reset players' total round bets here
                if (stage != GameStage.Showdown) {
                    currentStageBet = 0;
                    for (uint256 i = 0; i < numPlayers; i++) {
                        players[i].currentStageBet = 0;
                    }
                    // if a betting stage ends, the next player should be the dealer
                    // to prepare for the next reveal stage
                    currentPlayerIndex = dealerPosition;
                    // For a reveal stage, this isn't used, however, it should be reset at the start
                    // of the next betting stage
                    // lastRaiseIndex = currentPlayerIndex;
                } else {
                    // if a showdown stage ends, the next player should be the nextPlayer who
                    // should reveal their cards, followed by the remaining active players
                    currentPlayerIndex = nextPlayer;
                }
                return _moveToNextStage();
            } else {
                // in the middle of a betting stage with an active player left to act
                currentPlayerIndex = nextPlayer;
            }
            // TODO: handle a new round of poker after showdown or only 1 active players
        }
    }

    function _moveToNextStage() internal {
        stage = GameStage(uint256(stage) + 1);
        emit NewStage(stage);
    }

    // TODO: do we include all-in players in the count?
    // TODO: don't count players who joined the game after the round started
    function countActivePlayers() public view returns (uint8) {
        uint8 count = 0;
        for (uint8 i = 0; i < numPlayers; i++) {
            if (!players[i].hasFolded) {
                count++;
            }
        }
        return count;
    }

    function setCurrentPlayerIndex(uint256 _currentPlayerIndex) external {
        // only deckHandler contract can call this
        require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
        currentPlayerIndex = _currentPlayerIndex;
    }

    function setStage(GameStage _stage) external {
        // only deckHandler contract can call this
        require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
        stage = _stage;
    }

    function setDealerPosition(uint256 _dealerPosition) external {
        // only deckHandler contract can call this
        require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
        dealerPosition = _dealerPosition;
    }

    function setCommunityCards(uint8 index, string memory card) external {
        // only deckHandler contract can call this
        require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
        require(index < 5, "Invalid community card index");
        communityCards[index] = card;
    }

    function getPlayers() external view returns (Player[] memory) {
        Player[] memory playersArray = new Player[](numPlayers);
        for (uint256 i = 0; i < numPlayers; i++) {
            playersArray[i] = players[i];
        }
        return playersArray;
    }

    /**
     * @dev Returns the number of hands revealed by the players this round
     * @return The number of hands revealed
     */
    // function countOfHandsRevealed() public view returns (uint8) {
    //     uint8 count = 0;
    //     for (uint8 i = 0; i < numPlayers; i++) {
    //         if (strEq(players[i].cards[0], "") && strEq(players[i].cards[1], "")) {
    //             count++;
    //         }
    //     }
    //     return count;
    // }

    // Hand evaluation functions would go here
    // These would be called during showdown to determine winners
    // Implementation would include standard poker hand rankings
    // and logic for splitting pots in case of ties
}
