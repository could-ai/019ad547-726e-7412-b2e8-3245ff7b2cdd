enum Suit { spades, hearts, diamonds, clubs }
enum Rank { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }

class Card {
  final Suit suit;
  final Rank rank;

  Card(this.suit, this.rank);

  @override
  String toString() => '${rank.name} of ${suit.name}';

  String get symbol {
    switch (rank) {
      case Rank.two: return '2';
      case Rank.three: return '3';
      case Rank.four: return '4';
      case Rank.five: return '5';
      case Rank.six: return '6';
      case Rank.seven: return '7';
      case Rank.eight: return '8';
      case Rank.nine: return '9';
      case Rank.ten: return '10';
      case Rank.jack: return 'J';
      case Rank.queen: return 'Q';
      case Rank.king: return 'K';
      case Rank.ace: return 'A';
    }
  }
  
  int get value {
    return rank.index + 2;
  }
}

class Player {
  String name;
  int chips;
  List<Card> hand = [];
  bool isFolded = false;
  bool isBot;
  int currentBet = 0;

  Player({required this.name, required this.chips, this.isBot = false});

  void resetRound() {
    hand.clear();
    isFolded = false;
    currentBet = 0;
  }
}

enum GamePhase { preFlop, flop, turn, river, showdown }

enum HandRank {
  highCard, pair, twoPair, threeOfAKind, straight, flush, fullHouse, fourOfAKind, straightFlush, royalFlush
}
