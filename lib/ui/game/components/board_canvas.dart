import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../logic/board.dart';
import '../../../logic/cell.dart';
import '../../../logic/change.dart';

class CellInfo {
  final int cellRow;
  final int cellColumn;
  final int player;
  final int mass;
  final Change change;

  CellInfo({
    required this.cellRow,
    required this.cellColumn,
    required this.player,
    required this.mass,
    required this.change,
  });
}

class BoardCanvas {
  final Canvas canvas;
  final Size size;
  final ThemeData theme;
  final Board board;
  final double orbitProgress;
  final double materializationProgress;

  double get cellLength => size.width / board.width;

  double get cellGridGap => cellLength / 4;

  double get baseOrbRadius => cellLength / 8;

  BoardCanvas({
    required this.canvas,
    required this.size,
    required this.theme,
    required this.board,
    required this.orbitProgress,
    required this.materializationProgress,
  });

  void draw() {
    _drawGridSegments();
    _drawOrbs();
  }

  void _drawGridSegments() {
    final Board(:height, :width) = board;

    void drawCellGridSegments(final int cellRow, final int cellColumn) {
      if (cellRow > 0) {
        _drawHorizontalSegment(cellRow, cellColumn);
      }
      if (cellColumn > 0) {
        _drawVerticalSegment(cellRow, cellColumn);
      }
    }

    for (var cellRow = 0; cellRow < height; cellRow++) {
      for (var cellColumn = 0; cellColumn < width; cellColumn++) {
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
    final Board(:height, :width, :cellMatrix, :changeMatrix) = board;

    for (var cellRow = 0; cellRow < height; cellRow++) {
      for (var cellColumn = 0; cellColumn < width; cellColumn++) {
        final Cell(:player, :mass) = cellMatrix[cellRow][cellColumn];
        final change = changeMatrix[cellRow][cellColumn];

        if (player != null) {
          _drawCellOrbs(CellInfo(
            cellColumn: cellColumn,
            cellRow: cellRow,
            player: player,
            mass: mass,
            change: change,
          ));
        }
      }
    }
  }

  void _drawCellOrbs(final CellInfo cellInfo) {
    final CellInfo(:mass, :change) = cellInfo;
    for (var orbNumber = 0; orbNumber < mass; orbNumber++) {
      final lastOrbOfCell = orbNumber == mass - 1;

      _drawOrb(
        cellInfo,
        offsetFromCenter: baseOrbRadius * (0.25 + mass * 0.5),
        revolutionOffset: 2 * orbNumber * pi / mass,
        animateMaterialization: lastOrbOfCell && change == Change.materialized,
      );
    }
  }

  void _drawOrb(
    final CellInfo cellInfo, {
    required final double offsetFromCenter,
    required final double revolutionOffset,
    final bool animateMaterialization = false,
  }) {
    final CellInfo(:cellRow, :cellColumn, :player, :mass) = cellInfo;

    final cellCenter = Offset(
      (cellColumn + 0.5) * cellLength,
      (cellRow + 0.5) * cellLength,
    );

    final criticalMass =
        board.cellTypeAt(cellRow: cellRow, cellColumn: cellColumn).criticalMass;

    final randomRevolutionOffset =
        Random(31 * cellColumn + cellRow).nextDouble() * 2 * pi;

    final angle = switch (criticalMass - mass) {
          <= 1 => lerpDouble(-pi, pi, (orbitProgress * 8) % 1)!,
          2 => lerpDouble(-pi, pi, (orbitProgress * 4) % 1)!,
          _ => lerpDouble(-pi, pi, orbitProgress)!,
        } +
        revolutionOffset +
        randomRevolutionOffset;

    final orbCenter = Offset(
      cellCenter.dx + offsetFromCenter * cos(angle),
      cellCenter.dy + offsetFromCenter * sin(angle),
    );

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = playerColors[player];

    final orbRadius =
        baseOrbRadius * (animateMaterialization ? materializationProgress : 1);

    canvas.drawCircle(
      orbCenter,
      orbRadius,
      paint,
    );
  }
}
