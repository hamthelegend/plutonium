import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plutonium/logic/board.dart';
import 'package:plutonium/logic/constants.dart';
import 'package:plutonium/logic/matrix.dart';
import 'package:plutonium/ui/game/components/draw_rotated.dart';

class BoardCanvas extends StatefulWidget {
  final Board board;
  final void Function({
    required int cellColumn,
    required int cellRow,
  }) onPlayedAt;

  const BoardCanvas({super.key, required this.board, required this.onPlayedAt});

  @override
  State<BoardCanvas> createState() => _BoardCanvasState();
}

class _BoardCanvasState extends State<BoardCanvas>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  final rotationTween = Tween(begin: -pi, end: pi);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    animation = rotationTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((final status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
  }

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(builder: (final context, final constraints) {
      final supposedSegmentWidth = constraints.maxWidth / widget.board.width;
      final supposedSegmentHeight = constraints.maxHeight / widget.board.height;
      final gridSegmentLength =
          min(supposedSegmentWidth, supposedSegmentHeight);

      return GestureDetector(
        onTapUp: (final details) {
          final cellRow =
              (details.localPosition.dy / gridSegmentLength).truncate();
          final cellColumn =
              (details.localPosition.dx / gridSegmentLength).truncate();
          widget.onPlayedAt(cellRow: cellRow, cellColumn: cellColumn);
        },
        child: SizedBox(
          width: gridSegmentLength * widget.board.width,
          height: gridSegmentLength * widget.board.height,
          child: CustomPaint(
            painter: BoardPainter(
              theme: Theme.of(context),
              board: widget.board,
              angle: animation.value,
            ),
          ),
        ),
      );
    });
  }
}

class BoardPainter extends CustomPainter {
  final ThemeData theme;
  final Board board;
  final double angle;

  BoardPainter({required this.theme, required this.board, required this.angle});

  @override
  void paint(final Canvas canvas, final Size size) {
    final cellLength = size.width / board.width;
    drawGridSegments(size, canvas, cellLength);
    drawOrbs(canvas, size, cellLength);
  }

  void drawGridSegments(
      final Size size, final Canvas canvas, final double cellLength) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = cellLength / 16
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..strokeCap = StrokeCap.round;

    final gap = cellLength / 4;

    void drawGridSegment(final Offset p1, final Offset p2) {
      canvas.drawLine(p1, p2, paint);
    }

    void drawHorizontalSegment(final int cellRow, final int cellColumn) {
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

    void drawVerticalSegment(final int cellRow, final int cellColumn) {
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

    void drawCellGridSegments(final int cellRow, final int cellColumn) {
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

  void drawOrbs(final Canvas canvas, final Size size, final double cellLength) {
    final orbRadius = cellLength / 6;

    void drawOrbs(
      final int cellRow,
      final int cellColumn,
      final int player,
      final int mass,
    ) {
      void drawOrb([final double revolutionOffset = 0]) {
        final cellCenter = Offset(
          (cellColumn + 0.5) * cellLength,
          (cellRow + 0.5) * cellLength,
        );

        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = playerColors[player];

        final orbCenter = Offset(
          cellCenter.dx - (orbRadius * 1.25),
          cellCenter.dy,
        );

        canvas.drawRotated(cellCenter, angle + revolutionOffset, () {
          canvas.drawCircle(
            orbCenter,
            orbRadius,
            paint,
          );
        });
      }

      if (mass == 1) {
        drawOrb();
      } else if (mass == 2) {
        drawOrb();
        drawOrb(pi);
      } else {
        drawOrb();
        drawOrb(2 * pi / 3);
        drawOrb(4 * pi / 3);
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
  bool shouldRepaint(covariant final CustomPainter oldDelegate) {
    return false;
  }
}
