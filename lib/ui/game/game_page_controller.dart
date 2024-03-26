import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plutonium/ui/game/game_page.dart';

import '../../constants.dart';
import '../../logic/game.dart';

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
  late Game game;
  var showGameOverScreen = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    game = Game(
      playerCount: widget.playerCount,
      boardHeight: widget.boardSize.height,
      boardWidth: widget.boardSize.width,
    );
  }

  @override
  void didChangeDependencies() {
    // if (state.gameOver) {
    //   setState(() {
    //     showGameOverScreen = true;
    //   });
    // }
    super.didChangeDependencies();
  }

  @override
  Widget build(final BuildContext context) {
    void onPlayedAt({required final cellColumn, required final cellRow}) {
      game.play(cellRow: cellRow, cellColumn: cellColumn);
    }

    void onRestartGame() {
      game.restart();
      showGameOverScreen = false;
    }

    return StreamBuilder(
      stream: game.state,
      builder: (final context, final snapshot) {
        final state = snapshot.data;
        return state != null
            ? GamePage(
                state: state,
                onPlayedAt: onPlayedAt,
                showGameOverScreen: showGameOverScreen,
                onRestartGame: onRestartGame,
              )
            : const CircularProgressIndicator();
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
