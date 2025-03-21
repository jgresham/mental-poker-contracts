// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PokerHandEvaluator.sol";

contract TexasHoldemRoom {
    enum GameStage {
        Idle,
        Preflop,
        Flop,
        Turn,
        River,
        Showdown
    }

    enum Action {
        None,
        Call,
        Raise,
        Check,
        Fold
    }

    struct Player {
        address addr;
        uint256 chips;
        uint256 currentBet;
        bool hasFolded;
        bool isAllIn;
        bytes32[2] holeCards;
    }

    struct GameState {
        GameStage stage;
        uint256 pot;
        uint256 currentBet;
        uint256 smallBlind;
        uint256 bigBlind;
        uint256 dealerPosition;
        uint256 currentPlayerIndex;
        uint256 lastRaiseIndex;
        bytes32[5] communityCards;
        uint256 revealedCommunityCards;
    }

    uint256 public constant MAX_PLAYERS = 10;
    uint256 public constant MIN_PLAYERS = 2;

    Player[MAX_PLAYERS] public players;
    uint256 public numPlayers;
    GameState public gameState;
    mapping(address => uint256) public playerIndexes;
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

    constructor(uint256 _smallBlind, bool _isPrivate) {
        gameState.smallBlind = _smallBlind;
        gameState.bigBlind = _smallBlind * 2;
        gameState.stage = GameStage.Idle;
        handEvaluator = new PokerHandEvaluator();
        isPrivate = _isPrivate;
    }

    function joinGame() external payable {
        require(numPlayers < MAX_PLAYERS, "Room is full");
        require(msg.value > 0, "Must buy in with chips");
        require(playerIndexes[msg.sender] == 0, "Already in game");

        numPlayers++;
        uint256 playerIndex = numPlayers;
        players[playerIndex - 1] = Player({
            addr: msg.sender,
            chips: msg.value,
            currentBet: 0,
            hasFolded: false,
            isAllIn: false,
            holeCards: [bytes32(0), bytes32(0)]
        });
        playerIndexes[msg.sender] = playerIndex;
    }

    function startNewHand() external {
        require(numPlayers >= MIN_PLAYERS, "Not enough players");
        require(gameState.stage == GameStage.Idle, "Game in progress");

        // Reset game state
        gameState.stage = GameStage.Preflop;
        gameState.pot = 0;
        gameState.currentBet = gameState.bigBlind;
        gameState.dealerPosition = (gameState.dealerPosition + 1) % numPlayers;
        gameState.currentPlayerIndex = (gameState.dealerPosition + 3) % numPlayers; // Start after BB
        gameState.lastRaiseIndex = gameState.currentPlayerIndex;
        gameState.revealedCommunityCards = 0;

        // Reset player states
        for (uint256 i = 0; i < numPlayers; i++) {
            players[i].currentBet = 0;
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
        require(gameState.stage != GameStage.Idle, "Game not in progress");
        uint256 playerIndex = playerIndexes[msg.sender] - 1;
        require(playerIndex == gameState.currentPlayerIndex, "Not your turn");
        require(!players[playerIndex].hasFolded, "Player has folded");
        require(!players[playerIndex].isAllIn, "Player is all-in");

        if (action == Action.Fold) {
            players[playerIndex].hasFolded = true;
        } else if (action == Action.Call) {
            uint256 callAmount = gameState.currentBet - players[playerIndex].currentBet;
            require(players[playerIndex].chips >= callAmount, "Not enough chips");
            _placeBet(playerIndex, callAmount);
        } else if (action == Action.Raise) {
            require(raiseAmount > gameState.currentBet, "Raise must be higher than current bet");
            uint256 totalAmount = raiseAmount - players[playerIndex].currentBet;
            require(players[playerIndex].chips >= totalAmount, "Not enough chips");
            _placeBet(playerIndex, totalAmount);
            gameState.currentBet = raiseAmount;
            gameState.lastRaiseIndex = playerIndex;
        } else if (action == Action.Check) {
            require(players[playerIndex].currentBet == gameState.currentBet, "Must call or raise");
        }

        emit PlayerMoved(msg.sender, action, raiseAmount);

        // Move to next player or stage
        _progressGame();
    }

    function submitEncryptedHoleCards(bytes32[2] calldata cards) external {
        require(gameState.stage == GameStage.Preflop, "Wrong stage");
        uint256 playerIndex = playerIndexes[msg.sender] - 1;
        require(players[playerIndex].holeCards[0] == bytes32(0), "Cards already submitted");

        players[playerIndex].holeCards = cards;
    }

    function submitHoleCardCommitment(bytes32 commitment) external {
        require(gameState.stage == GameStage.Preflop, "Wrong stage");
        uint256 playerIndex = playerIndexes[msg.sender] - 1;
        require(players[playerIndex].holeCards[0] == bytes32(0), "Cards already submitted");

        commitments[msg.sender] = commitment;
    }

    function revealHoleCards(PokerHandEvaluator.Card[2] memory cards, bytes32 secret) external {
        require(gameState.stage == GameStage.Showdown, "Not showdown stage");
        require(!players[playerIndexes[msg.sender] - 1].hasFolded, "Player folded");

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
            players[playerIndexes[winner] - 1].chips += winAmount;
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
        players[playerIndex].currentBet += amount;
        gameState.pot += amount;

        if (players[playerIndex].chips == 0) {
            players[playerIndex].isAllIn = true;
        }
    }

    function _progressGame() internal {
        uint256 nextPlayer = _findNextActivePlayer(gameState.currentPlayerIndex);

        // Check if betting round is complete
        if (nextPlayer == gameState.lastRaiseIndex || _countActivePlayers() == 1) {
            _moveToNextStage();
        } else {
            gameState.currentPlayerIndex = nextPlayer;
        }
    }

    function _moveToNextStage() internal {
        if (gameState.stage == GameStage.Preflop) {
            gameState.stage = GameStage.Flop;
            gameState.revealedCommunityCards = 3;
        } else if (gameState.stage == GameStage.Flop) {
            gameState.stage = GameStage.Turn;
            gameState.revealedCommunityCards = 4;
        } else if (gameState.stage == GameStage.Turn) {
            gameState.stage = GameStage.River;
            gameState.revealedCommunityCards = 5;
        } else if (gameState.stage == GameStage.River) {
            gameState.stage = GameStage.Showdown;
        }

        // Reset betting for new stage
        if (gameState.stage != GameStage.Showdown) {
            gameState.currentBet = 0;
            for (uint256 i = 0; i < numPlayers; i++) {
                players[i].currentBet = 0;
            }
            gameState.currentPlayerIndex = (gameState.dealerPosition + 1) % numPlayers;
            gameState.lastRaiseIndex = gameState.currentPlayerIndex;
        }

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

    // Hand evaluation functions would go here
    // These would be called during showdown to determine winners
    // Implementation would include standard poker hand rankings
    // and logic for splitting pots in case of ties
}
