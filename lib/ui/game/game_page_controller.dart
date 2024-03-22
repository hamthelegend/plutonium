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
  Widget build(BuildContext context) {
    return GamePage(
      state: state,
      onPlayedAt: ({required cellColumn, required cellRow}) => setState(() {
        state = state.playedAt(
          cellRow: cellRow,
          cellColumn: cellColumn,
        );
      }),
    );
  }
}
