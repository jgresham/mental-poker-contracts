// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

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
        bool hasChecked;
        string[2] cards;
        uint8 seatPosition;
        uint256 handScore;
        bool joinedAndWaitingForNextRound;
        bool leavingAfterRoundEnds;
    }

    uint256 public roundNumber;
    GameStage public stage;
    uint256 public pot;
    uint256 public currentStageBet; // per player (to stay in the round)
    uint256 public smallBlind;
    uint256 public bigBlind;
    uint8 public dealerPosition;
    /**
     * @dev The current player that should take an action (background or bet action)
     * This is the index of the player in the players array. Not the seat position.
     */
    uint8 public currentPlayerIndex;
    uint8 public lastRaiseIndex;

    uint8 public constant MAX_PLAYERS = 10;
    uint8 public constant MIN_PLAYERS = 2;
    uint8 public constant EMPTY_SEAT = 255;
    uint256 public constant STARTING_CHIPS = 1000;

    CryptoUtils public cryptoUtils;
    DeckHandler public deckHandler;

    Player[MAX_PLAYERS] public players;
    uint8[MAX_PLAYERS] public seatPositionToPlayerIndex;
    uint8 public numPlayers;
    bool public isPrivate;

    event GameStarted(uint256 dealerPosition);
    event NewStage(GameStage stage);
    event PlayerMoved(address indexed player, Action indexed action, uint256 amount);
    event PotWon(address[] winners, uint8[] winnerPlayerIndexes, uint256 amount);
    // event THP_Log(string message);

    constructor(address _cryptoUtils, uint256 _smallBlind, bool _isPrivate) {
        cryptoUtils = CryptoUtils(_cryptoUtils);
        smallBlind = _smallBlind;
        bigBlind = _smallBlind * 2;
        stage = GameStage.Idle;
        roundNumber = 0;
        isPrivate = _isPrivate;
        dealerPosition = 0;
        currentPlayerIndex = 0;
        numPlayers = 0;
        // possibly move this to setDeckHandler() to reduce initcode size
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            seatPositionToPlayerIndex[i] = EMPTY_SEAT;
            players[i] = Player({
                addr: address(0),
                chips: 0,
                currentStageBet: 0,
                totalRoundBet: 0,
                hasFolded: false,
                hasChecked: false,
                isAllIn: false,
                cards: ["", ""],
                seatPosition: i,
                handScore: 0,
                joinedAndWaitingForNextRound: false,
                leavingAfterRoundEnds: false
            });
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
    function getPlayerIndexFromAddr(address addr) external view returns (uint8) {
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i].addr == addr) {
                return i;
            }
        }
        revert("Player not found for given address");
    }

    /**
     * @dev Finds the next active player index clockwise of the current player using seat position
     * @dev Skips players that have folded or are all-in
     * @dev Returns the current player index if no active players are found
     */
    function getNextActivePlayer(bool requireActive) public view returns (uint8) {
        // get the current player's seat position
        uint8 currentSeatPosition = players[currentPlayerIndex].seatPosition; // 1, 1
        // loop over the players in the ascending order of their seat positions
        // until we find an active player
        // TODO: create a number of players that played in the current round and use that for the modulo
        // and for the next seat index. (don't use players that joined the game after the round started)
        // todo : % numPlayers or % MAX_PLAYERS?
        uint8 nextSeatIndex = (currentSeatPosition + 1) % MAX_PLAYERS; // 2 % 2 = 0
        while (nextSeatIndex != currentSeatPosition) {
            // TODO: add a status for a player that has joined, but did not start the round
            uint8 playerIndex = seatPositionToPlayerIndex[nextSeatIndex];
            // skip empty seats and players that joined after the round started
            if (playerIndex != EMPTY_SEAT) {
                Player memory checkPlayer = players[playerIndex];
                if (!checkPlayer.joinedAndWaitingForNextRound) {
                    // TODO: check if the player has cards (joined before the round started)
                    if (!requireActive) {
                        return playerIndex;
                    }
                    if (!checkPlayer.hasFolded && !checkPlayer.isAllIn) {
                        return playerIndex;
                    }
                }
            }
            nextSeatIndex = (nextSeatIndex + 1) % MAX_PLAYERS;
        }
        // if no active players are found, return the current player
        return currentPlayerIndex;
    }

    function removePlayer(uint8 playerIndex) internal {
        players[playerIndex].joinedAndWaitingForNextRound = false;
        seatPositionToPlayerIndex[players[playerIndex].seatPosition] = EMPTY_SEAT;
        numPlayers--;
    }

    /**
     * @dev This function is callable by players in the room. If the player is currently waiting
     * for the next round to start, they will be removed from the room immediately.
     *
     * @dev If the player is currently in the middle of a round (folded or active),
     * they will be removed from the room at the end of the round.
     */
    function leaveGame() external {
        uint8 playerIndex = this.getPlayerIndexFromAddr(msg.sender);
        require(playerIndex != EMPTY_SEAT, "Player not in game");
        if (players[playerIndex].joinedAndWaitingForNextRound) {
            // set their seat as empty and remove their player from the players array
            removePlayer(playerIndex);
        } else {
            // will be removed from the game at the end of the round
            players[playerIndex].leavingAfterRoundEnds = true;
        }
    }

    // fully new function
    function joinGame() external {
        require(numPlayers < MAX_PLAYERS, "Room is full");
        // Check if player is already in the game
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i].addr == msg.sender) {
                revert("Already in game");
            }
        }

        // Find the first empty seat
        uint8 seatPosition = 0;
        while (seatPositionToPlayerIndex[seatPosition] != EMPTY_SEAT && seatPosition < MAX_PLAYERS)
        {
            seatPosition++;
        }
        // This should never happen if seats are set empty correctly as players leave the game
        require(seatPosition < MAX_PLAYERS, "No empty seats");

        // find the first player in the players array which is a null player (addr == 0)
        uint8 nullPlayerIndex = 0;
        while (players[nullPlayerIndex].addr != address(0) && nullPlayerIndex < MAX_PLAYERS) {
            nullPlayerIndex++;
        }
        require(nullPlayerIndex < MAX_PLAYERS, "No empty players");
        require(players[nullPlayerIndex].addr == address(0), "Null player index not found");

        bool isRoundPastIdleStage = stage >= GameStage.Idle;

        players[nullPlayerIndex] = Player({
            addr: msg.sender,
            chips: STARTING_CHIPS,
            currentStageBet: 0,
            totalRoundBet: 0,
            hasFolded: false,
            hasChecked: false,
            isAllIn: false,
            cards: ["", ""],
            seatPosition: seatPosition,
            handScore: 0,
            joinedAndWaitingForNextRound: isRoundPastIdleStage,
            leavingAfterRoundEnds: false
        });
        seatPositionToPlayerIndex[seatPosition] = nullPlayerIndex;
        numPlayers++;

        if (numPlayers >= MIN_PLAYERS && !isPrivate) {
            _progressGame();
        }
    }

    function resetRound() external {
        require(
            msg.sender == address(0x2a99EC82d658F7a77DdEbFd83D0f8F591769cB64)
                || msg.sender == address(0x101a25d0FDC4E9ACa9fA65584A28781046f1BeEe),
            "Only Johns can call this"
        );
        // return chips to players
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            players[i].chips += players[i].totalRoundBet;
        }
        _startNewHand();
    }

    function _startNewHand() internal {
        // do this check later after processing players waiting to join? or move game stage to idle.
        // require(numPlayers >= MIN_PLAYERS, "Not enough players");
        // todo: ? stage might be any stage if players fold or showdown?
        // require(stage == GameStage.Idle, "Game in progress");

        // Reset game state
        roundNumber++;
        stage = GameStage.Shuffle;
        pot = 0;
        currentStageBet = 0;
        // todo: blinds
        // currentStageBet = bigBlind;
        // These are all indexes into the players array, but the dealer position is based
        // on the seat position of the players.
        uint8 previousDealerSeatPosition = players[dealerPosition].seatPosition;

        // Process players that are leaving/have left the game here
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i].leavingAfterRoundEnds) {
                removePlayer(i);
            }
        }

        // process players that joined the game after the round started
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i].joinedAndWaitingForNextRound) {
                players[i].joinedAndWaitingForNextRound = false;
            }
        }

        if (numPlayers < MIN_PLAYERS) {
            // not enough players to start the round
            stage = GameStage.Idle;
            dealerPosition = 0;
            currentPlayerIndex = 0;
            return;
        }

        // Now that all player join/leaves have been processed, update the dealer position
        // and the current player index
        // The next dealer position is the next player clockwise of the previous dealer
        // So loop through all the seats until we find the next dealer, starting from the previous dealer
        // and wrap around if necessary
        uint8 nextDealerSeatPosition = (previousDealerSeatPosition + 1) % MAX_PLAYERS;
        while (
            seatPositionToPlayerIndex[nextDealerSeatPosition] == EMPTY_SEAT
                && nextDealerSeatPosition != previousDealerSeatPosition
        ) {
            nextDealerSeatPosition = (nextDealerSeatPosition + 1) % MAX_PLAYERS;
        }
        require(
            seatPositionToPlayerIndex[nextDealerSeatPosition] != EMPTY_SEAT,
            "Next dealer must not be an empty seat"
        );
        require(
            nextDealerSeatPosition != previousDealerSeatPosition,
            "Next dealer must not be the previous dealer"
        );
        dealerPosition = seatPositionToPlayerIndex[nextDealerSeatPosition];
        currentPlayerIndex = dealerPosition; // dealer always starts shuffling
        lastRaiseIndex = currentPlayerIndex; // todo: check if this is correct

        // Reset player states
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            players[i].currentStageBet = 0;
            players[i].totalRoundBet = 0;
            players[i].hasFolded = false;
            players[i].hasChecked = false;
            players[i].isAllIn = false;
            players[i].cards = ["", ""];
        }

        // todo: blinds
        // uint256 sbPosition = (dealerPosition + 1) % numPlayers;
        // uint256 bbPosition = (dealerPosition + 2) % numPlayers;

        // _placeBet(sbPosition, smallBlind);
        // _placeBet(bbPosition, bigBlind);

        // reset the deck
        deckHandler.resetDeck();

        stage = GameStage.Idle;
        _progressGame();
    }

    // mostly fully tested function
    function submitAction(Action action, uint256 raiseAmount) external {
        require(
            stage == GameStage.Preflop || stage == GameStage.Flop || stage == GameStage.Turn
                || stage == GameStage.River,
            "Game not in a betting stage"
        );
        uint8 playerIndex = this.getPlayerIndexFromAddr(msg.sender);
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
            players[playerIndex].hasChecked = true;
        }

        emit PlayerMoved(msg.sender, action, raiseAmount);

        // Move to next player or stage
        _progressGame();
    }

    // /**
    //  * @dev Reveals the player's cards.
    //  * @dev Many todos: validate the encrypted cards, the card indexes for the player are valid (getCardIndexForPlayer in js),
    //  * @dev and that it is appropriate (showdown/all-in) to reveal cards.
    //  * @param encryptedCard1 The player's encrypted card 1 [c1, c2]
    //  * @param encryptedCard2 The player's encrypted card 2 [c1, c2]
    //  * @param privateKey The player's private key
    //  * @param c1Inverse The inverse of the player's c1 modulo inverse for decryption
    //  */
    // function revealMyCards(
    //     bytes[2] memory encryptedCard1,
    //     bytes[2] memory encryptedCard2,
    //     bytes memory privateKey,
    //     bytes memory c1Inverse
    // ) external returns (string memory card1, string memory card2) {
    //     uint256 playerIndex = this.getPlayerIndexFromAddr(msg.sender);
    //     require(!players[playerIndex].hasFolded, "Player folded");
    //     require(
    //         cryptoUtils.strEq(players[playerIndex].cards[0], ""),
    //         "Player already revealed cards (0) in this round"
    //     );
    //     require(
    //         cryptoUtils.strEq(players[playerIndex].cards[1], ""),
    //         "Player already revealed cards (1) in this round"
    //     );
    //     // todo: verify that the c2 of the cards is the same value in encrypted deck

    //     // Create an instance of CryptoUtils to call its functions
    //     BigNumber memory privateKeyBN = BigNumbers.init(privateKey, false);
    //     BigNumber memory c1InverseBN = BigNumbers.init(c1Inverse, false);
    //     CryptoUtils.EncryptedCard memory encryptedCard1Struct = CryptoUtils.EncryptedCard({
    //         c1: BigNumbers.init(encryptedCard1[0], false),
    //         c2: BigNumbers.init(encryptedCard1[1], false)
    //     });
    //     CryptoUtils.EncryptedCard memory encryptedCard2Struct = CryptoUtils.EncryptedCard({
    //         c1: BigNumbers.init(encryptedCard2[0], false),
    //         c2: BigNumbers.init(encryptedCard2[1], false)
    //     });
    //     BigNumber memory decryptedCard1 =
    //         cryptoUtils.verifyDecryptCard(encryptedCard1Struct, privateKeyBN, c1InverseBN);
    //     BigNumber memory decryptedCard2 =
    //         cryptoUtils.verifyDecryptCard(encryptedCard2Struct, privateKeyBN, c1InverseBN);

    //     // convert the decrypted cards to a string
    //     card1 = cryptoUtils.decodeBigintMessage(decryptedCard1);
    //     card2 = cryptoUtils.decodeBigintMessage(decryptedCard2);
    //     players[playerIndex].cards[0] = card1;
    //     players[playerIndex].cards[1] = card2;

    //     // Get the player's hand score (using player's cards and community cards) from HandEvaluator
    //     string[5] memory communityCards = deckHandler.getCommunityCards();
    //     // Combine player cards and community cards into a single array
    //     string[7] memory allCards;
    //     allCards[0] = card1;
    //     allCards[1] = card2;
    //     allCards[2] = communityCards[0];
    //     allCards[3] = communityCards[1];
    //     allCards[4] = communityCards[2];
    //     allCards[5] = communityCards[3];
    //     allCards[6] = communityCards[4];
    //     PokerHandEvaluatorv2.Hand memory playerHand = handEvaluator.findBestHandExternal(allCards);
    //     uint256 playerHandScore = playerHand.score;
    //     players[playerIndex].handScore = playerHandScore;

    //     emit PlayerCardsRevealed(
    //         address(msg.sender), card1, card2, playerHand.rank, playerHandScore
    //     );

    //     // return true if the encrypted cards match the decrypted cards from the deck?

    //     // put in progressGame()?
    //     if (countOfHandsRevealed() == countActivePlayers()) {
    //         // find the winners and split the pot
    //         determineWinners();
    //         // Should start a new round
    //         _progressGame();
    //     }
    //     return (card1, card2);
    // }

    function determineWinners() internal {
        require(
            stage == GameStage.Showdown || countActivePlayers() == 1,
            "Not showdown stage or more than 1 active player"
        );

        // Evaluate hands and find winners
        // Can be tie if best 5 cards are the same (eg. community cards)
        uint256 highestScore = 0;
        uint8[] memory winnerPlayerIndexes = new uint8[](countOfHandsRevealed());
        uint8 winnerCount = 0;

        if (countActivePlayers() == 1) {
            // only 1 active player, so they win the pot
            uint8 lastActivePlayerIndex;
            for (uint8 i = 0; i < MAX_PLAYERS; i++) {
                if (!players[i].hasFolded) {
                    lastActivePlayerIndex = i;
                    break;
                }
            }
            winnerPlayerIndexes[0] = lastActivePlayerIndex;
            winnerCount = 1;
        } else {
            for (uint8 i = 0; i < MAX_PLAYERS; i++) {
                uint256 handScore = players[i].handScore;
                if (handScore == 0) {
                    // player was not active or "alive" at the end of the round
                    continue;
                }
                if (handScore > highestScore) {
                    // New highest hand
                    highestScore = handScore;
                    winnerPlayerIndexes[0] = i;
                    winnerCount = 1;
                } else if (handScore == highestScore) {
                    // Tie
                    winnerPlayerIndexes[winnerCount] = i;
                    winnerCount++;
                }
            }
        }

        // Distribute pot
        // todo: what to do with the remainder fractional chips?
        // use 6th or 7th card to decide who gets the "odd chip" (remainder)
        uint256 winAmount = pot / winnerCount;
        for (uint8 i = 0; i < winnerCount; i++) {
            uint8 winnerPlayerIndex = winnerPlayerIndexes[i];
            players[winnerPlayerIndex].chips += winAmount;
        }
        address[] memory winnerAddrs = new address[](winnerPlayerIndexes.length);
        for (uint8 i = 0; i < winnerCount; i++) {
            winnerAddrs[i] = players[winnerPlayerIndexes[i]].addr;
        }
        emit PotWon(winnerAddrs, winnerPlayerIndexes, winAmount);
    }

    function _placeBet(uint8 playerIndex, uint256 amount) internal {
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
        // reset the game state
        // reset the players's statuses, cards, etc,
        // todo: remove waiting player's status
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
            // mark all players waiting for the next round as not joined
            for (uint8 i = 0; i < MAX_PLAYERS; i++) {
                if (players[i].joinedAndWaitingForNextRound) {
                    players[i].joinedAndWaitingForNextRound = false;
                }
            }
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
            uint8 nextRevealPlayer = getNextActivePlayer(requireActive);
            if (nextRevealPlayer == dealerPosition) {
                // emit THP_Log("_progressGame() if nextRevealPlayer == dealerPosition");
                // after a reveal stage, we enter a betting stage
                // always the first active player LEFT of the dealer starts all betting stages

                // After shuffle, we are still in a reveal stage
                if (stage == GameStage.Shuffle) {
                    currentPlayerIndex = dealerPosition;
                } else {
                    bool requireActiveForBetting = true;
                    currentPlayerIndex = dealerPosition;
                    uint8 nextActivePlayer = getNextActivePlayer(requireActiveForBetting);
                    currentPlayerIndex = nextActivePlayer;
                    // at the start of a betting stage, the last raise index is the first active player by default
                    lastRaiseIndex = nextActivePlayer;
                }

                return _moveToNextStage();
            } else {
                // otherwise, the next player should submit their decryption values
                currentPlayerIndex = nextRevealPlayer;
            }
        } else if (stage == GameStage.Showdown) {
            if (countOfHandsRevealed() == countActivePlayers()) {
                // find the winners and split the pot
                determineWinners();
                // Should start a new round
                _startNewHand(); // moves game to idle/shuffling stage
            }
            // do nothing while the rest of the players reveal their cards
            return;
        } else {
            // current in a betting stage

            // if there are no more active players, the round ends and the last
            // active player wins the pot
            if (countActivePlayers() == 1) {
                // todo: split the pot
                determineWinners();
                _startNewHand();
                return;
                // emit THP_Log("_progressGame() if _countActivePlayers() == 1");
            }

            // if the last raise index is the same as the next active player index,
            // the betting stage is complete.
            // Reset the round bet amounts and move to the next stage
            bool requireActive = true;
            uint8 nextPlayer = getNextActivePlayer(requireActive);
            // Check if betting round is complete
            if (nextPlayer == lastRaiseIndex) {
                // emit THP_Log("_progressGame() if nextPlayer == lastRaiseIndex");
                // Reset betting for a new betting stage
                // do not reset players' total round bets here
                currentStageBet = 0;
                for (uint8 i = 0; i < MAX_PLAYERS; i++) {
                    players[i].currentStageBet = 0;
                    players[i].hasChecked = false;
                }
                // if a betting stage ends, the next player should be the dealer
                // to prepare for the next reveal stage
                currentPlayerIndex = dealerPosition;
                // For a reveal stage, this isn't used, however, it should be reset at the start
                // of the next betting stage
                // lastRaiseIndex = currentPlayerIndex;
                return _moveToNextStage();
            } else {
                // in the middle of a betting stage with an active player left to act
                currentPlayerIndex = nextPlayer;
            }
            // TODO: handle a new round of poker after showdown or only 1 active players
        }
    }

    function _moveToNextStage() internal {
        stage = GameStage(uint8(stage) + 1);
        emit NewStage(stage);
    }

    // TODO: do we include all-in players in the count?
    // TODO: don't count players who joined the game after the round started
    function countActivePlayers() public view returns (uint8) {
        uint8 count = 0;
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i].addr != address(0) && !players[i].hasFolded) {
                count++;
            }
        }
        return count;
    }

    // function setCurrentPlayerIndex(uint8 _currentPlayerIndex) external {
    //     // only deckHandler contract can call this
    //     require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
    //     currentPlayerIndex = _currentPlayerIndex;
    // }

    // function setStage(GameStage _stage) external {
    //     // only deckHandler contract can call this
    //     require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
    //     stage = _stage;
    // }

    function setPlayerHandScore(uint8 playerIndex, uint256 handScore) external {
        require(msg.sender == address(deckHandler), "Only DeckHandler can call this");
        players[playerIndex].handScore = handScore;
    }

    function getPlayers() external view returns (Player[] memory) {
        Player[] memory playersArray = new Player[](MAX_PLAYERS);
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            playersArray[i] = players[i];
        }
        return playersArray;
    }

    function getPlayer(uint8 playerIndex) external view returns (Player memory) {
        return players[playerIndex];
    }

    function countPlayersAtRoundStart() external view returns (uint8) {
        uint8 count = 0;
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            if (players[i].addr != address(0) && players[i].joinedAndWaitingForNextRound == false) {
                count++;
            }
        }
        return count;
    }

    function getPlayersCardIndexes(uint8 playerIndex)
        external
        view
        returns (uint8[2] memory playerCardIndexes)
    {
        uint8 countOfPlayersCounterClockwiseToDealer = 0;
        uint8 playerSeatPosition = players[playerIndex].seatPosition;
        uint8 dealerSeatPosition = players[dealerPosition].seatPosition;
        while (playerSeatPosition != dealerSeatPosition) {
            playerSeatPosition = (playerSeatPosition - 1 + MAX_PLAYERS) % MAX_PLAYERS;
            if (
                seatPositionToPlayerIndex[playerSeatPosition] != EMPTY_SEAT
                    && !players[seatPositionToPlayerIndex[playerSeatPosition]].joinedAndWaitingForNextRound
            ) {
                countOfPlayersCounterClockwiseToDealer++;
            }
        }
        uint8 playersAtRoundStart = this.countPlayersAtRoundStart();
        playerCardIndexes[0] = countOfPlayersCounterClockwiseToDealer;
        playerCardIndexes[1] = countOfPlayersCounterClockwiseToDealer + playersAtRoundStart;
        return playerCardIndexes;
    }

    /**
     * @dev Returns the number of hands revealed by the players this round by
     * checking if the player's hand score is greater than 0
     * @return The number of hands revealed
     */
    function countOfHandsRevealed() public view returns (uint8) {
        uint8 count = 0;
        for (uint8 i = 0; i < MAX_PLAYERS; i++) {
            // This is set to 0 after each round,
            // so players with a score have just revealed their cards
            if (players[i].handScore > 0) {
                count++;
            }
        }
        return count;
    }
}
