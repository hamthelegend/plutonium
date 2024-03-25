import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:plutonium/logic/matrix.dart';
import 'package:plutonium/ui/util/canvas/draw_rotated.dart';

import '../../../constants.dart';
import '../../../logic/board.dart';

typedef CellInfo = ({int cellRow, int cellColumn, int player, int mass});

class BoardCanvas {
  final Canvas canvas;
  final Size size;
  final ThemeData theme;
  final Board board;
  final double animationProgress;

  double get cellLength => size.width / board.width;

  double get cellGridGap => cellLength / 4;

  double get orbRadius => cellLength / 8;

  BoardCanvas({
    required this.canvas,
    required this.size,
    required this.theme,
    required this.board,
    required this.animationProgress,
  });

  void draw() {
    _drawGridSegments();
    _drawOrbs();
  }

  void _drawGridSegments() {
    void drawCellGridSegments(final int cellRow, final int cellColumn) {
      if (cellRow > 0) {
        _drawHorizontalSegment(cellRow, cellColumn);
      }
      if (cellColumn > 0) {
        _drawVerticalSegment(cellRow, cellColumn);
      }
    }

    for (var cellRow = 0; cellRow < board.height; cellRow++) {
      for (var cellColumn = 0; cellColumn < board.width; cellColumn++) {
        drawCellGridSegments(cellRow, cellColumn);
      }
    }
  }

  void _drawHorizontalSegment(final int cellRow, final int cellColumn) {
    _drawGridSegment(
      Offset(
        cellColumn * cellLength + cellGridGap / 2,
        cellRow * cellLength,
      ),
      Offset(
        (cellColumn + 1) * cellLength - cellGridGap / 2,
        cellRow * cellLength,
      ),
    );
  }

  void _drawVerticalSegment(final int cellRow, final int cellColumn) {
    _drawGridSegment(
      Offset(
        cellColumn * cellLength,
        cellRow * cellLength + cellGridGap / 2,
      ),
      Offset(
        cellColumn * cellLength,
        (cellRow + 1) * cellLength - cellGridGap / 2,
      ),
    );
  }

  void _drawGridSegment(final Offset p1, final Offset p2) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellLength / 16
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(p1, p2, paint);
  }

  void _drawOrbs() {
    final cellMatrix = board.cellMatrix.toMatrix();
    for (var cellRow = 0; cellRow < board.height; cellRow++) {
      for (var cellColumn = 0; cellColumn < board.width; cellColumn++) {
        final cell = cellMatrix[cellRow][cellColumn];
        final player = cell.player;

        if (player != null) {
          _drawCellOrbs((
            cellColumn: cellColumn,
            cellRow: cellRow,
            player: player,
            mass: cell.mass,
          ));
        }
      }
    }
  }

  void _drawCellOrbs(final CellInfo cellInfo) {
    if (cellInfo.mass == 1) {
      _drawOrb(cellInfo, offsetFromCenter: orbRadius * 0.75);
    } else if (cellInfo.mass == 2) {
      final offsetFromCenter = orbRadius * 1.25;
      _drawOrb(cellInfo, offsetFromCenter: offsetFromCenter);
      _drawOrb(
        cellInfo,
        offsetFromCenter: offsetFromCenter,
        revolutionOffset: pi,
      );
    } else {
      final offsetFromCenter = orbRadius * 1.75;
      _drawOrb(cellInfo, offsetFromCenter: offsetFromCenter);
      _drawOrb(
        cellInfo,
        offsetFromCenter: offsetFromCenter,
        revolutionOffset: 2 * pi / 3,
      );
      _drawOrb(
        cellInfo,
        offsetFromCenter: offsetFromCenter,
        revolutionOffset: 4 * pi / 3,
      );
    }
  }

  void _drawOrb(
    final CellInfo cellInfo, {
    required final double offsetFromCenter,
    final double revolutionOffset = 0,
  }) {
    final (:cellRow, :cellColumn, :player, :mass) = cellInfo;

    final cellCenter = Offset(
      (cellColumn + 0.5) * cellLength,
      (cellRow + 0.5) * cellLength,
    );

    final criticalMass =
        board.cellTypeAt(cellRow: cellRow, cellColumn: cellColumn).criticalMass;

    final angle = switch (criticalMass - mass) {
      <= 1 => lerpDouble(-pi, pi, (animationProgress * 8) % 1)!,
      2 => lerpDouble(-pi, pi, (animationProgress * 4) % 1)!,
      _ => lerpDouble(-pi, pi, animationProgress)!,
    };

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = playerColors[player];

    final orbCenter = Offset(
      cellCenter.dx - offsetFromCenter,
      cellCenter.dy,
    );

    final randomRevolutionOffset =
        Random(31 * cellColumn + cellRow).nextDouble() * 2 * pi;

    canvas.drawRotated(
      cellCenter,
      angle + revolutionOffset + randomRevolutionOffset,
      () {
        canvas.drawCircle(
          orbCenter,
          orbRadius,
          paint,
        );
      },
    );
  }
}
