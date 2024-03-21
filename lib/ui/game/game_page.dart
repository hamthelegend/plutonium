import 'package:flutter/material.dart';
import 'package:plutonium/logic/game_state.dart';
import 'package:plutonium/ui/game/components/board_canvas.dart';

class GamePage extends StatelessWidget {
  final GameState state;
  final void Function({
    required int cellColumn,
    required int cellRow,
  }) onPlayedAt;

  const GamePage({
    super.key,
    required this.state,
    required this.onPlayedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Player ${state.currentPlayer + 1}'s turn")),
      body: Center(
        child: BoardCanvas(
          board: state.table.board,
          onPlayedAt: onPlayedAt,
        ),
      ),
    );
  }
}
