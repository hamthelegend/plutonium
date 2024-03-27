import 'package:flutter/material.dart';
import 'package:plutonium/ui/game/components/board_canvas.dart';

import '../../../logic/board.dart';

class BoardPainter extends CustomPainter {
  final ThemeData theme;
  final Board board;
  final double orbitProgress;
  final double materializationProgress;

  BoardPainter({
    required this.theme,
    required this.board,
    required this.orbitProgress,
    required this.materializationProgress,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    BoardCanvas(
      canvas: canvas,
      size: size,
      theme: theme,
      board: board,
      orbitProgress: orbitProgress,
      materializationProgress: materializationProgress,
    ).draw();
  }

  @override
  bool shouldRepaint(covariant final BoardPainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress;
  }
}
