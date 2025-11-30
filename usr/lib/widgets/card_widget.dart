import 'package:flutter/material.dart';
import '../models/poker_models.dart';

class CardWidget extends StatelessWidget {
  final PokerCard? card;
  final bool isHidden;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    this.card,
    this.isHidden = false,
    this.width = 60,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    if (isHidden) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          image: const DecorationImage(
            image: NetworkImage('https://www.transparenttextures.com/patterns/diagmonds-light.png'), // Fallback pattern or just color
            fit: BoxFit.cover,
            opacity: 0.2
          )
        ),
        child: Center(
          child: Icon(Icons.diamond, color: Colors.blue.shade200, size: 20),
        ),
      );
    }

    if (card == null) return SizedBox(width: width, height: height);

    Color suitColor = (card!.suit == Suit.hearts || card!.suit == Suit.diamonds)
        ? Colors.red
        : Colors.black;

    IconData suitIcon;
    switch (card!.suit) {
      case Suit.hearts: suitIcon = Icons.favorite; break;
      case Suit.diamonds: suitIcon = Icons.diamond; break;
      case Suit.clubs: suitIcon = Icons.eco; break; // Closest to club
      case Suit.spades: suitIcon = Icons.spa; break; // Closest to spade
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(1, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card!.symbol,
            style: TextStyle(
              color: suitColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Icon(suitIcon, color: suitColor, size: 20),
        ],
      ),
    );
  }
}
