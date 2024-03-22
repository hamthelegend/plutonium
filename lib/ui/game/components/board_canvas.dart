import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plutonium/logic/board.dart';
import 'package:plutonium/logic/constants.dart';
import 'package:plutonium/logic/matrix.dart';

class BoardCanvas extends StatelessWidget {
  final Board board;
  final void Function({
    required int cellColumn,
    required int cellRow,
  }) onPlayedAt;

  const BoardCanvas({super.key, required this.board, required this.onPlayedAt});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final supposedSegmentWidth = constraints.maxWidth / board.width;
      final supposedSegmentHeight = constraints.maxHeight / board.height;
      final gridSegmentLength =
          min(supposedSegmentWidth, supposedSegmentHeight);

      return GestureDetector(
        onTapUp: (details) {
          final cellRow =
              (details.localPosition.dy / gridSegmentLength).truncate();
          final cellColumn =
              (details.localPosition.dx / gridSegmentLength).truncate();
          onPlayedAt(cellRow: cellRow, cellColumn: cellColumn);
        },
        child: SizedBox(
          width: gridSegmentLength * board.width,
          height: gridSegmentLength * board.height,
          child: CustomPaint(
              painter: BoardPainter(
            theme: Theme.of(context),
            board: board,
          )),
        ),
      );
    });
  }
}

class BoardPainter extends CustomPainter {
  final ThemeData theme;
  final Board board;

  BoardPainter({required this.theme, required this.board});

  @override
  void paint(Canvas canvas, Size size) {
    final cellLength = size.width / board.width;
    drawGridSegments(size, canvas, cellLength);
    drawOrbs(canvas, size, cellLength);
  }

  void drawGridSegments(Size size, Canvas canvas, double cellLength) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellLength / 16
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..strokeCap = StrokeCap.round;

    const gap = 16;

    void drawGridSegment(Offset p1, Offset p2) {
      canvas.drawLine(p1, p2, paint);
    }

    void drawHorizontalSegment(int cellRow, int cellColumn) {
      drawGridSegment(
        Offset(
          cellColumn * cellLength + gap / 2,
          cellRow * cellLength,
        ),
        Offset(
          (cellColumn + 1) * cellLength - gap / 2,
          cellRow * cellLength,
        ),
      );
    }

    void drawVerticalSegment(int cellRow, int cellColumn) {
      drawGridSegment(
        Offset(
          cellColumn * cellLength,
          cellRow * cellLength + gap / 2,
        ),
        Offset(
          cellColumn * cellLength,
          (cellRow + 1) * cellLength - gap / 2,
        ),
      );
    }

    void drawCellGridSegments(int cellRow, int cellColumn) {
      if (cellRow > 0) {
        drawHorizontalSegment(cellRow, cellColumn);
      }
      if (cellColumn > 0) {
        drawVerticalSegment(cellRow, cellColumn);
      }
    }

    for (var cellRow = 0; cellRow < board.height; cellRow++) {
      for (var cellColumn = 0; cellColumn < board.width; cellColumn++) {
        drawCellGridSegments(cellRow, cellColumn);
      }
    }
  }

  void drawOrbs(Canvas canvas, Size size, double cellLength) {
    final orbRadius = cellLength / 6;

    void drawOrbs(int cellRow, int cellColumn, int player, int mass) {
      void drawOrb(Offset center) {
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = playerColors[player];

        canvas.drawCircle(center, orbRadius, paint);
      }

      if (mass == 1) {
        drawOrb(Offset(
          (cellColumn + 0.5) * cellLength,
          (cellRow + 0.5) * cellLength,
        ));
      } else if (mass == 2) {
        drawOrb(Offset(
          (cellColumn + 0.35) * cellLength,
          (cellRow + 0.35) * cellLength,
        ));
        drawOrb(Offset(
          (cellColumn + 0.65) * cellLength,
          (cellRow + 0.65) * cellLength,
        ));
      } else {
        final triangleBase = orbRadius * 2.5; // adjusted from 2 to 3
        final triangleHeight = triangleBase * sqrt(3) / 2;

        drawOrb(Offset(
          (cellColumn + 0.5) * cellLength,
          (cellRow + 0.5) * cellLength - triangleHeight / 2,
        ));
        drawOrb(Offset(
          (cellColumn + 0.5) * cellLength - triangleBase / 2,
          (cellRow + 0.5) * cellLength + triangleHeight / 2,
        ));
        drawOrb(Offset(
          (cellColumn + 0.5) * cellLength + triangleBase / 2,
          (cellRow + 0.5) * cellLength + triangleHeight / 2,
        ));
      }
    }

    final cellMatrix = board.cellMatrix.toMatrix();
    for (var cellRow = 0; cellRow < board.height; cellRow++) {
      for (var cellColumn = 0; cellColumn < board.width; cellColumn++) {
        final cell = cellMatrix[cellRow][cellColumn];
        final player = cell.player;

        if (player != null) {
          drawOrbs(cellRow, cellColumn, player, cell.mass);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}