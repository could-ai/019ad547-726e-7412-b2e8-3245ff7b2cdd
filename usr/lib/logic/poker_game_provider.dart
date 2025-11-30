import 'dart:math';
import 'package:flutter/material.dart';
import '../models/poker_models.dart';

class PokerGameProvider extends ChangeNotifier {
  List<PokerCard> _deck = [];
  List<PokerCard> communityCards = [];
  List<Player> players = [];
  int pot = 0;
  int currentBet = 0; // The amount to call
  int currentPlayerIndex = 0;
  int dealerIndex = 0;
  GamePhase currentPhase = GamePhase.preFlop;
  String gameStatus = "Welcome to Texas Hold'em";
  bool isGameRunning = false;

  PokerGameProvider() {
    _initializePlayers();
  }

  void _initializePlayers() {
    players = [
      Player(name: "You", chips: 1000, isBot: false),
      Player(name: "Bot 1", chips: 1000, isBot: true),
      Player(name: "Bot 2", chips: 1000, isBot: true),
      Player(name: "Bot 3", chips: 1000, isBot: true),
    ];
  }

  void startGame() {
    if (players[0].chips <= 0) {
      gameStatus = "Game Over! You ran out of chips.";
      notifyListeners();
      return;
    }
    
    isGameRunning = true;
    _resetRound();
    _shuffleDeck();
    _dealHoleCards();
    _postBlinds();
    gameStatus = "Pre-Flop: Your turn.";
    notifyListeners();
  }

  void _resetRound() {
    communityCards.clear();
    _deck.clear();
    pot = 0;
    currentBet = 0;
    currentPhase = GamePhase.preFlop;
    for (var p in players) {
      p.resetRound();
    }
    // Rotate dealer
    dealerIndex = (dealerIndex + 1) % players.length;
    // Start with player to left of big blind (simplified: start with player 0 for now or rotate)
    currentPlayerIndex = 0; 
  }

  void _shuffleDeck() {
    _deck = [];
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        _deck.add(PokerCard(suit, rank));
      }
    }
    _deck.shuffle(Random());
  }

  void _dealHoleCards() {
    // Deal 2 cards to each player
    for (int i = 0; i < 2; i++) {
      for (var player in players) {
        if (_deck.isNotEmpty) {
          player.hand.add(_deck.removeLast());
        }
      }
    }
  }

  void _postBlinds() {
    // Simplified blinds for MVP
    int smallBlind = 10;
    int bigBlind = 20;
    
    // In a real game, blinds rotate. Here we just force a small ante from everyone for simplicity in single player flow
    for (var p in players) {
      if (p.chips >= 10) {
        p.chips -= 10;
        pot += 10;
      }
    }
    currentBet = 0; // Reset for betting round
  }

  void playerAction(String action) {
    if (!isGameRunning) return;
    
    Player player = players[0]; // User is always index 0

    if (action == 'FOLD') {
      player.isFolded = true;
      gameStatus = "You Folded.";
    } else if (action == 'CALL') {
      int callAmount = currentBet - player.currentBet;
      if (player.chips >= callAmount) {
        player.chips -= callAmount;
        player.currentBet += callAmount;
        pot += callAmount;
        gameStatus = "You Called.";
      }
    } else if (action == 'RAISE') {
      int raiseAmount = 50; // Fixed raise for MVP
      if (player.chips >= raiseAmount + (currentBet - player.currentBet)) {
        int total = raiseAmount + (currentBet - player.currentBet);
        player.chips -= total;
        player.currentBet += total;
        pot += total;
        currentBet += raiseAmount;
        gameStatus = "You Raised.";
      }
    }

    _nextTurn();
  }

  void _nextTurn() {
    // Move to next player
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;

    // Check if round is complete (simplified: if back to user)
    if (currentPlayerIndex == 0) {
      _advancePhase();
    } else {
      // Bot turn
      _processBotTurn();
    }
    notifyListeners();
  }

  void _processBotTurn() async {
    // Simulate thinking time
    await Future.delayed(const Duration(milliseconds: 600));
    
    Player bot = players[currentPlayerIndex];
    if (bot.isFolded) {
      _nextTurn();
      return;
    }

    // Simple Bot Logic
    // 10% chance to fold, 20% raise, 70% call/check
    int roll = Random().nextInt(100);
    
    if (roll < 10) {
      bot.isFolded = true;
    } else if (roll < 30) {
      // Raise
      int raiseAmt = 20;
      if (bot.chips >= raiseAmt + (currentBet - bot.currentBet)) {
         int total = raiseAmt + (currentBet - bot.currentBet);
         bot.chips -= total;
         bot.currentBet += total;
         pot += total;
         currentBet += raiseAmt;
      } else {
        // Call if can't raise
        int callAmt = currentBet - bot.currentBet;
        if (bot.chips >= callAmt) {
          bot.chips -= callAmt;
          bot.currentBet += callAmt;
          pot += callAmt;
        }
      }
    } else {
      // Call / Check
      int callAmt = currentBet - bot.currentBet;
      if (bot.chips >= callAmt) {
        bot.chips -= callAmt;
        bot.currentBet += callAmt;
        pot += callAmt;
      } else {
        bot.isFolded = true; // Fold if can't afford
      }
    }
    
    notifyListeners();
    _nextTurn();
  }

  void _advancePhase() {
    // Reset player bets for the new round
    for (var p in players) p.currentBet = 0;
    currentBet = 0;

    if (currentPhase == GamePhase.preFlop) {
      currentPhase = GamePhase.flop;
      _dealCommunity(3);
      gameStatus = "Flop dealt.";
    } else if (currentPhase == GamePhase.flop) {
      currentPhase = GamePhase.turn;
      _dealCommunity(1);
      gameStatus = "Turn dealt.";
    } else if (currentPhase == GamePhase.turn) {
      currentPhase = GamePhase.river;
      _dealCommunity(1);
      gameStatus = "River dealt.";
    } else if (currentPhase == GamePhase.river) {
      currentPhase = GamePhase.showdown;
      _determineWinner();
    }
    notifyListeners();
  }

  void _dealCommunity(int count) {
    for (int i = 0; i < count; i++) {
      if (_deck.isNotEmpty) {
        communityCards.add(_deck.removeLast());
      }
    }
  }

  void _determineWinner() {
    // MVP: Random winner or High Card logic
    // Implementing a full 7-card evaluator is complex. 
    // For this demo, we will sum card values.
    
    Player? winner;
    int bestScore = -1;

    List<Player> activePlayers = players.where((p) => !p.isFolded).toList();

    if (activePlayers.isEmpty) {
      gameStatus = "Everyone folded.";
      isGameRunning = false;
      return;
    }

    for (var p in activePlayers) {
      int score = 0;
      // Sum hole cards
      for (var c in p.hand) score += c.value;
      // Add community cards (simplified evaluation)
      for (var c in communityCards) score += c.value;
      
      if (score > bestScore) {
        bestScore = score;
        winner = p;
      }
    }

    if (winner != null) {
      winner.chips += pot;
      gameStatus = "Winner: ${winner.name} (Score: $bestScore)";
      pot = 0;
    }
    isGameRunning = false;
    notifyListeners();
  }
}
