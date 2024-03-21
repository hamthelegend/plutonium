import 'package:flutter/material.dart';

import '../../logic/constants.dart';

class GamePage extends StatelessWidget {
  final int playerCount;
  final BoardSize boardSize;

  const GamePage({
    super.key,
    required this.playerCount,
    required this.boardSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Player count: $playerCount'),
        Text('Board size: $boardSize'),
      ],
    );
  }
}
