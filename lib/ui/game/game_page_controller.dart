import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return GamePage(
      playerCount: widget.playerCount,
      boardSize: widget.boardSize,
    );
  }
}
