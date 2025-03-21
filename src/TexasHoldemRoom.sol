// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PokerHandEvaluator.sol";
import "./BigNumbers/BigNumbers.sol";

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
        Showdown // 10

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
        bytes32[2] holeCards;
    }

    struct GameState {
        GameStage stage;
        uint256 pot;
        uint256 currentStageBet;
        uint256 smallBlind;
        uint256 bigBlind;
        uint256 dealerPosition;
        uint256 currentPlayerIndex;
        uint256 lastRaiseIndex;
        bytes32[5] communityCards;
        uint256 revealedCommunityCards;
        BigNumber[] encryptedDeck;
    }

    uint256 public constant MAX_PLAYERS = 10;
    uint256 public constant MIN_PLAYERS = 2;

    Player[MAX_PLAYERS] public players;
    uint256 public numPlayers;
    GameState public gameState;
    bool public isPrivate;

    PokerHandEvaluator public handEvaluator;
    mapping(address => PokerHandEvaluator.Card[2]) public revealedHoleCards;
    mapping(address => bytes32) public commitments;
    mapping(address => bytes32) public secrets;

    event GameStarted(uint256 dealerPosition);
    event NewStage(GameStage stage);
    event PlayerMoved(address indexed player, Action indexed action, uint256 amount);
    event PotWon(address indexed winner, uint256 amount);
    event HandRevealed(address indexed player, uint8 card1Rank, uint8 card2Rank);
    event EncryptedShuffleSubmitted(address indexed player, BigNumber[] encryptedShuffle);
    event DecryptionValuesSubmitted(address indexed player, uint8[] cardIndexes, BigNumber[] decryptionValues);

    constructor(uint256 _smallBlind, bool _isPrivate) {
        gameState.smallBlind = _smallBlind;
        gameState.bigBlind = _smallBlind * 2;
        gameState.stage = GameStage.Idle;
        handEvaluator = new PokerHandEvaluator();
        // Initialize each element of the array individually to avoid copying memory to storage
        for (uint256 i = 0; i < 52; i++) {
            gameState.encryptedDeck.push(BigNumber({val: "0", neg: false, bitlen: 2048}));
        }
        isPrivate = _isPrivate;
        // set dealer position to 0
        gameState.dealerPosition = 0;
        gameState.currentPlayerIndex = 0;
    }

    // fully new function
    function getPlayerIndexFromAddr(address addr) internal view returns (uint256) {
        for (uint256 i = 0; i < numPlayers; i++) {
            if (players[i].addr == addr) {
                return i;
            }
        }
        // put addr in error message
        string memory errorMessage = string(abi.encodePacked("Player not found: ", addressToString(addr)));
        revert(errorMessage);
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
        players[numPlayers - 1] = Player({
            addr: msg.sender,
            chips: 1000,
            currentStageBet: 0,
            totalRoundBet: 0,
            hasFolded: false,
            isAllIn: false,
            holeCards: [bytes32(0), bytes32(0)]
        });

        if (numPlayers >= MIN_PLAYERS && !isPrivate) {
            _progressGame();
        }
    }

    // fully new function
    function submitEncryptedShuffle(BigNumber[] memory encryptedShuffle) external {
        require(gameState.stage == GameStage.Shuffle, "Wrong stage");
        require(gameState.currentPlayerIndex == getPlayerIndexFromAddr(msg.sender), "Not your turn to shuffle");

        // Store shuffle as an action?
        emit EncryptedShuffleSubmitted(msg.sender, encryptedShuffle);

        // Copy each element individually since direct array assignment is not supported
        for (uint256 i = 0; i < encryptedShuffle.length; i++) {
            gameState.encryptedDeck[i] = encryptedShuffle[i];
        }

        gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % numPlayers;
        // if we are back at the dealer, move to the next stage
        if (gameState.currentPlayerIndex == gameState.dealerPosition) {
            gameState.stage = GameStage.RevealDeal;
        }
    }

    // fully new function
    function submitDecryptionValues(uint8[] memory cardIndexes, BigNumber[] memory decryptionValues) external {
        require(
            gameState.stage == GameStage.RevealDeal || gameState.stage == GameStage.RevealFlop
                || gameState.stage == GameStage.RevealTurn || gameState.stage == GameStage.RevealRiver,
            "Game is not in a reveal stage"
        );
        require(gameState.currentPlayerIndex == getPlayerIndexFromAddr(msg.sender), "Not your turn to decrypt");
        require(cardIndexes.length == decryptionValues.length, "Mismatch in cardIndexes and decryptionValues lengths");
        // TODO: verify decryption values?
        // TODO: verify decryption indexes
        emit DecryptionValuesSubmitted(msg.sender, cardIndexes, decryptionValues);

        for (uint256 i = 0; i < cardIndexes.length; i++) {
            gameState.encryptedDeck[cardIndexes[i]] = decryptionValues[i];
        }
        _progressGame();
        // gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % numPlayers;
        // // if we are back at the dealer, move to the next stage
        // if (gameState.currentPlayerIndex == gameState.dealerPosition) {
        // if (gameState.stage == GameStage.RevealDeal) {
        //     gameState.stage = GameStage.Preflop;
        // } else if (gameState.stage == GameStage.RevealFlop) {
        //     gameState.stage = GameStage.Flop;
        // } else if (gameState.stage == GameStage.RevealTurn) {
        //     gameState.stage = GameStage.Turn;
        // } else if (gameState.stage == GameStage.RevealRiver) {
        //     gameState.stage = GameStage.River;
        // }
        // }
    }

    function startNewHand() external {
        require(numPlayers >= MIN_PLAYERS, "Not enough players");
        require(gameState.stage == GameStage.Idle, "Game in progress");

        // Reset game state
        gameState.stage = GameStage.Preflop;
        gameState.pot = 0;
        gameState.currentStageBet = gameState.bigBlind;
        gameState.dealerPosition = (gameState.dealerPosition + 1) % numPlayers;
        gameState.currentPlayerIndex = (gameState.dealerPosition + 3) % numPlayers; // Start after BB
        gameState.lastRaiseIndex = gameState.currentPlayerIndex;
        gameState.revealedCommunityCards = 0;

        // Reset player states
        for (uint256 i = 0; i < numPlayers; i++) {
            players[i].currentStageBet = 0;
            players[i].totalRoundBet = 0;
            players[i].hasFolded = false;
            players[i].isAllIn = false;
            players[i].holeCards = [bytes32(0), bytes32(0)];
        }

        // Post blinds
        uint256 sbPosition = (gameState.dealerPosition + 1) % numPlayers;
        uint256 bbPosition = (gameState.dealerPosition + 2) % numPlayers;

        _placeBet(sbPosition, gameState.smallBlind);
        _placeBet(bbPosition, gameState.bigBlind);

        emit GameStarted(gameState.dealerPosition);
        emit NewStage(GameStage.Preflop);
    }

    function submitAction(Action action, uint256 raiseAmount) external {
        require(
            gameState.stage == GameStage.Preflop || gameState.stage == GameStage.Flop
                || gameState.stage == GameStage.Turn || gameState.stage == GameStage.River,
            "Game not in a betting stage"
        );
        uint256 playerIndex = getPlayerIndexFromAddr(msg.sender);
        require(playerIndex == gameState.currentPlayerIndex, "Not your turn");
        require(!players[playerIndex].hasFolded, "Player has folded");
        require(!players[playerIndex].isAllIn, "Player is all-in");

        if (action == Action.Fold) {
            players[playerIndex].hasFolded = true;
        } else if (action == Action.Call) {
            uint256 callAmount = gameState.currentStageBet - players[playerIndex].currentStageBet;
            require(players[playerIndex].chips >= callAmount, "Not enough chips");
            _placeBet(playerIndex, callAmount);
        } else if (action == Action.Raise) {
            require(raiseAmount > gameState.currentStageBet, "Raise must be higher than current bet");
            uint256 totalAmount = raiseAmount - players[playerIndex].currentStageBet;
            require(players[playerIndex].chips >= totalAmount, "Not enough chips");
            _placeBet(playerIndex, totalAmount);
            gameState.currentStageBet = raiseAmount;
            gameState.lastRaiseIndex = playerIndex;
        } else if (action == Action.Check) {
            require(players[playerIndex].currentStageBet == gameState.currentStageBet, "Must call or raise");
        }

        emit PlayerMoved(msg.sender, action, raiseAmount);

        // Move to next player or stage
        _progressGame();
    }

    function submitEncryptedHoleCards(bytes32[2] calldata cards) external {
        require(gameState.stage == GameStage.Preflop, "Wrong stage");
        uint256 playerIndex = getPlayerIndexFromAddr(msg.sender);
        require(players[playerIndex].holeCards[0] == bytes32(0), "Cards already submitted");

        players[playerIndex].holeCards = cards;
    }

    function submitHoleCardCommitment(bytes32 commitment) external {
        require(gameState.stage == GameStage.Preflop, "Wrong stage");
        uint256 playerIndex = getPlayerIndexFromAddr(msg.sender);
        require(players[playerIndex].holeCards[0] == bytes32(0), "Cards already submitted");

        commitments[msg.sender] = commitment;
    }

    function revealHoleCards(PokerHandEvaluator.Card[2] memory cards, bytes32 secret) external {
        require(gameState.stage == GameStage.Showdown, "Not showdown stage");
        uint256 playerIndex = getPlayerIndexFromAddr(msg.sender);
        require(!players[playerIndex].hasFolded, "Player folded");

        // Verify commitment
        bytes32 commitment = keccak256(abi.encode(cards, secret));
        require(commitment == commitments[msg.sender], "Invalid revelation");

        // Copy cards one by one
        revealedHoleCards[msg.sender][0] = cards[0];
        revealedHoleCards[msg.sender][1] = cards[1];
        secrets[msg.sender] = secret;

        emit HandRevealed(msg.sender, cards[0].rank, cards[1].rank);
    }

    function determineWinners() external {
        require(gameState.stage == GameStage.Showdown, "Not showdown stage");

        address[] memory activePlayers = new address[](numPlayers);
        uint256 activeCount = 0;

        // Get active players who revealed their hands
        for (uint256 i = 0; i < numPlayers; i++) {
            address playerAddr = players[i].addr;
            if (!players[i].hasFolded && revealedHoleCards[playerAddr][0].rank != 0) {
                activePlayers[activeCount] = playerAddr;
                activeCount++;
            }
        }

        require(activeCount > 0, "No hands revealed");

        // Convert community cards from bytes32 to Card struct
        PokerHandEvaluator.Card[5] memory communityCards;
        for (uint256 i = 0; i < 5; i++) {
            // In a real implementation, you would decode the bytes32 into rank and suit
            // This is a placeholder for the actual decoding logic
            (uint8 rank, uint8 suit) = decodeCard(gameState.communityCards[i]);
            communityCards[i] = PokerHandEvaluator.Card({rank: rank, suit: suit});
        }

        // Evaluate hands and find winners
        uint256 highestScore = 0;
        address[] memory winners = new address[](activeCount);
        uint256 winnerCount = 0;

        for (uint256 i = 0; i < activeCount; i++) {
            address playerAddr = activePlayers[i];
            PokerHandEvaluator.Hand memory hand =
                handEvaluator.evaluateHand(revealedHoleCards[playerAddr], communityCards);

            if (hand.score > highestScore) {
                // New highest hand
                highestScore = hand.score;
                winners[0] = playerAddr;
                winnerCount = 1;
            } else if (hand.score == highestScore) {
                // Tie
                winners[winnerCount] = playerAddr;
                winnerCount++;
            }
        }

        // Distribute pot
        uint256 winAmount = gameState.pot / winnerCount;
        for (uint256 i = 0; i < winnerCount; i++) {
            address winner = winners[i];
            uint256 winnerIndex = getPlayerIndexFromAddr(winner);
            if (winnerIndex >= 0) {
                players[winnerIndex].chips += winAmount;
            } else {
                // TODO: Handle case where winner is not in the game?
            }
            emit PotWon(winner, winAmount);
        }

        // Reset game state
        gameState.stage = GameStage.Idle;
        gameState.pot = 0;

        // Clear revealed cards and commitments
        for (uint256 i = 0; i < numPlayers; i++) {
            address playerAddr = players[i].addr;
            delete revealedHoleCards[playerAddr];
            delete commitments[playerAddr];
            delete secrets[playerAddr];
        }
    }

    function decodeCard(bytes32 encoded) internal pure returns (uint8 rank, uint8 suit) {
        rank = uint8(uint256(encoded) >> 248);
        suit = uint8(uint256(encoded) >> 240);
    }

    function _placeBet(uint256 playerIndex, uint256 amount) internal {
        require(players[playerIndex].chips >= amount, "Not enough chips");
        players[playerIndex].chips -= amount;
        players[playerIndex].currentStageBet += amount;
        players[playerIndex].totalRoundBet += amount;
        gameState.pot += amount;

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

    /**
     * @dev Increments the current player index and moves to the next stage
     * @dev If in a reveal stage, all players need to submit their decryption values
     * @dev If in a betting stage, only the players who are not all-in
     * @dev and not folded need to submit their actions
     * @notice Emits a NewStage event and new current player index event
     */
    function _progressGame() internal {
        if (gameState.stage == GameStage.Idle) {
            return _moveToNextStage();
        }

        // shuffle or reveal stage
        if (
            gameState.stage == GameStage.Shuffle || gameState.stage == GameStage.RevealDeal
                || gameState.stage == GameStage.RevealFlop || gameState.stage == GameStage.RevealTurn
                || gameState.stage == GameStage.RevealRiver
        ) {
            // if we are back at the dealer, move to the next stage
            // since the dealer starts all reveal stages
            if (gameState.currentPlayerIndex == gameState.dealerPosition) {
                // after a reveal stage, we enter a betting stage
                // always the first active player LEFT of the dealer starts all betting stages
                uint256 nextPlayer = _findNextActivePlayer(gameState.currentPlayerIndex);
                gameState.currentPlayerIndex = nextPlayer;
                return _moveToNextStage();
            } else {
                // otherwise, the next player should submit their decryption values
                gameState.currentPlayerIndex = (gameState.currentPlayerIndex + 1) % numPlayers;
            }
        } else {
            // betting stage or showdown
            // if there are no more active players, the round ends and the last
            // active player wins the pot
            if (_countActivePlayers() == 1) {
                _endRound();
            }
            // if the last raise index is the same as the next active player index,
            // the betting stage is complete.
            // Reset the round bet amounts and move to the next stage
            uint256 nextPlayer = _findNextActivePlayer(gameState.currentPlayerIndex);
            // Check if betting round is complete
            if (nextPlayer == gameState.lastRaiseIndex) {
                // Reset betting for a new betting stage
                // do not reset players' total round bets here
                if (gameState.stage != GameStage.Showdown) {
                    gameState.currentStageBet = 0;
                    for (uint256 i = 0; i < numPlayers; i++) {
                        players[i].currentStageBet = 0;
                    }
                    // if a betting stage ends, the next player should be the dealer
                    // to prepare for the next reveal stage
                    gameState.currentPlayerIndex = gameState.dealerPosition;
                    gameState.lastRaiseIndex = gameState.currentPlayerIndex;
                } else {
                    // if a showdown stage ends, the next player should be the nextPlayer who
                    // should reveal their cards, followed by the remaining active players
                    gameState.currentPlayerIndex = nextPlayer;
                }
                return _moveToNextStage();
            } else {
                gameState.currentPlayerIndex = nextPlayer;
            }
            // TODO: handle a new round of poker after showdown or only 1 active players
        }
    }

    function _moveToNextStage() internal {
        gameState.stage = GameStage(uint256(gameState.stage) + 1);
        emit NewStage(gameState.stage);
    }

    function _findNextActivePlayer(uint256 currentIndex) internal view returns (uint256) {
        uint256 nextIndex = (currentIndex + 1) % numPlayers;
        while (nextIndex != currentIndex) {
            if (!players[nextIndex].hasFolded && !players[nextIndex].isAllIn) {
                return nextIndex;
            }
            nextIndex = (nextIndex + 1) % numPlayers;
        }
        return currentIndex;
    }

    function _countActivePlayers() internal view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < numPlayers; i++) {
            if (!players[i].hasFolded) {
                count++;
            }
        }
        return count;
    }

    function getStage() external view returns (GameStage) {
        return gameState.stage;
    }

    function getDealerPosition() external view returns (uint256) {
        return gameState.dealerPosition;
    }

    function getCurrentPlayerIndex() external view returns (uint256) {
        return gameState.currentPlayerIndex;
    }

    // Hand evaluation functions would go here
    // These would be called during showdown to determine winners
    // Implementation would include standard poker hand rankings
    // and logic for splitting pots in case of ties

    // Helper functions to convert address to string
    function addressToString(address _addr) internal pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(_addr);
        bytes memory stringBytes = new bytes(42);

        // Add "0x" prefix
        stringBytes[0] = "0";
        stringBytes[1] = "x";

        // Convert each byte to hex characters
        for (uint256 i = 0; i < 20; i++) {
            uint8 b = uint8(addressBytes[i]);
            uint8 hi = b / 16;
            uint8 lo = b - 16 * hi;

            stringBytes[2 + 2 * i] = byteToChar(hi);
            stringBytes[3 + 2 * i] = byteToChar(lo);
        }

        return string(stringBytes);
    }

    // Helper function to convert byte to hex character
    function byteToChar(uint8 b) internal pure returns (bytes1) {
        if (b < 10) {
            return bytes1(uint8(b) + 0x30); // 0-9
        } else {
            return bytes1(uint8(b) + 0x57); // a-f
        }
    }
}
