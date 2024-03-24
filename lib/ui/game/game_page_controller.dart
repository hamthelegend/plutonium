import 'package:flutter/material.dart';
import 'package:plutonium/logic/game_state.dart';
import 'package:plutonium/ui/game/game_page.dart';

import '../../logic/constants.dart';

class GamePageController extends StatefulWidget {
  final int playerCount;
  final BoardSize boardSize;

  const GamePageController({
    super.key,
    required this.playerCount,
    required this.boardSize,
  });

  @override
  State<GamePageController> createState() => _GamePageControllerState();
}

class _GamePageControllerState extends State<GamePageController> {
  late GameState state;
  var showGameOverScreen = false;

  @override
  void initState() {
    super.initState();
    state = GameState.ofSize(
      playerCount: widget.playerCount,
      boardWidth: widget.boardSize.width,
      boardHeight: widget.boardSize.height,
    );
  }

  @override
  void didChangeDependencies() {
    if (state.gameOver) {
      setState(() {
        showGameOverScreen = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(final BuildContext context) {
    void onPlayedAt({required final cellColumn, required final cellRow}) {
      setState(() {
        state = state.playedAt(
          cellRow: cellRow,
          cellColumn: cellColumn,
        );

        while (state.table.board.critical) {
          state = state.reacted();
        }
      });
    }

    void onRestartGame() {
      setState(() {
        state = GameState.ofSize(
          playerCount: widget.playerCount,
          boardWidth: widget.boardSize.width,
          boardHeight: widget.boardSize.height,
        );
        showGameOverScreen = false;
      });
    }

    return GamePage(
      state: state,
      onPlayedAt: onPlayedAt,
      showGameOverScreen: showGameOverScreen,
      onRestartGame: onRestartGame,
    );
  }
}
