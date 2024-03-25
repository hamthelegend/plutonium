import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plutonium/logic/game_state.dart';
import 'package:plutonium/ui/game/game_page.dart';

import '../../constants.dart';

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
  Timer? timer;

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
        if (state.board.critical) {
            state = state.reacted();
        }
      });

      timer?.cancel();
      timer = Timer.periodic(reactionAnimationSpeed, (final timer) {
        if (state.board.critical) {
          setState(() {
            state = state.reacted();
          });
        } else {
          timer.cancel();
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
