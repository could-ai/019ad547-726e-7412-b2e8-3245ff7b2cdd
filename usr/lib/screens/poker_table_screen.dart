import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/poker_game_provider.dart';
import '../models/poker_models.dart';
import '../widgets/card_widget.dart';

class PokerTableScreen extends StatelessWidget {
  const PokerTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF35654d), // Poker table green
      appBar: AppBar(
        title: const Text('Texas Hold\'em Poker'),
        backgroundColor: const Color(0xFF2a503d),
        elevation: 0,
      ),
      body: Consumer<PokerGameProvider>(
        builder: (context, game, child) {
          return Stack(
            children: [
              // Table Design
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    color: const Color(0xFF35654d),
                    borderRadius: BorderRadius.circular(200),
                    border: Border.all(color: const Color(0xFF5c3a21), width: 15), // Wood rim
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 20, spreadRadius: 5)
                    ],
                  ),
                ),
              ),

              // Community Cards & Pot
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pot: \$${game.pot}',
                      style: const TextStyle(color: Colors.yellowAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: game.communityCards
                          .map((c) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CardWidget(card: c),
                              ))
                          .toList(),
                    ),
                    if (game.communityCards.isEmpty)
                      Container(
                        height: 90,
                        width: 300,
                        alignment: Alignment.center,
                        child: Text(
                          game.gameStatus,
                          style: const TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      ),
                  ],
                ),
              ),

              // Bots (Top)
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPlayer(game.players[1], isCurrent: game.currentPlayerIndex == 1),
                    _buildPlayer(game.players[2], isCurrent: game.currentPlayerIndex == 2),
                    _buildPlayer(game.players[3], isCurrent: game.currentPlayerIndex == 3),
                  ],
                ),
              ),

              // User (Bottom)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: _buildPlayer(game.players[0], isCurrent: game.currentPlayerIndex == 0, isUser: true),
                ),
              ),

              // Controls
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!game.isGameRunning)
                      ElevatedButton(
                        onPressed: () => game.startGame(),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        child: const Text('DEAL HAND', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                    else if (game.currentPlayerIndex == 0) ...[
                      FloatingActionButton.extended(
                        heroTag: 'fold',
                        onPressed: () => game.playerAction('FOLD'),
                        backgroundColor: Colors.red,
                        label: const Text('Fold'),
                      ),
                      FloatingActionButton.extended(
                        heroTag: 'call',
                        onPressed: () => game.playerAction('CALL'),
                        backgroundColor: Colors.blue,
                        label: const Text('Call/Check'),
                      ),
                      FloatingActionButton.extended(
                        heroTag: 'raise',
                        onPressed: () => game.playerAction('RAISE'),
                        backgroundColor: Colors.green,
                        label: const Text('Raise'),
                      ),
                    ] else
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          'Waiting for ${game.players[game.currentPlayerIndex].name}...',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlayer(Player player, {bool isCurrent = false, bool isUser = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isCurrent ? Border.all(color: Colors.yellow, width: 3) : null,
            color: player.isFolded ? Colors.grey : Colors.black45,
          ),
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.brown.shade300,
            child: Text(player.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
          child: Text('\$${player.chips}', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        if (!player.isFolded)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: player.hand.map((c) {
              // Show cards if it's the user OR if the game is in showdown phase
              bool showCard = isUser || (player.hand.isNotEmpty && player.hand.first.value > 0 && c == player.hand.first && false); 
              // Actually, logic for showdown:
              // We need access to game phase here, but for simplicity, let's just hide bots until we implement full showdown reveal logic in provider
              // For now: User sees their cards. Bots hide cards.
              // UPDATE: Let's allow seeing bot cards if game is over (winner determined)
              // Since we don't have easy access to 'isGameOver' flag here without passing it, we'll keep it simple.
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: CardWidget(
                  card: c, 
                  isHidden: !isUser && !player.isBot, // Logic placeholder: !isUser means hidden usually
                  // Actually, let's just hide all bot cards for now unless we add a 'reveal' flag to player
                  width: 40,
                  height: 60,
                ),
              );
            }).toList(),
          )
        else
          const Text('FOLDED', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }
}
