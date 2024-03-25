import 'package:flutter/material.dart';
import 'package:plutonium/logic/game_state.dart';
import 'package:plutonium/ui/game/components/board_canvas.dart';

class GamePage extends StatelessWidget {
  final GameState state;
  final void Function({
    required int cellColumn,
    required int cellRow,
  }) onPlayedAt;
  final bool showGameOverScreen;
  final VoidCallback onRestartGame;

  const GamePage({
    super.key,
    required this.state,
    required this.onPlayedAt,
    required this.showGameOverScreen,
    required this.onRestartGame,
  });

  @override
  Widget build(final BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((final timeStamp) {
      if (state.gameOver) {
        final friendlyWinner = (state.winner ?? 0) + 1;

        showDialog(
          context: context,
          builder: (final buildContext) => AlertDialog(
            title: const Text('Game over'),
            content: Text('Player $friendlyWinner won!'),
            actions: [
              TextButton(
                onPressed: () {
                  onRestartGame();
                  Navigator.pop(context);
                },
                child: const Text('Okay'),
              ),
            ],
          ),
        );
      };
    });

    return Scaffold(
      appBar: AppBar(title: Text("Player ${state.currentPlayer + 1}'s turn")),
      body: Center(
        child: BoardCanvas(
          board: state.board,
          onPlayedAt: onPlayedAt,
        ),
      ),
    );
  }
}
