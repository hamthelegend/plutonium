import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plutonium/logic/board.dart';
import 'package:plutonium/logic/constants.dart';
import 'package:plutonium/logic/matrix.dart';
import 'package:plutonium/ui/util/animation/controlled_animation.dart';
import 'package:plutonium/ui/util/canvas/draw_rotated.dart';

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
  final rotationTween = Tween(begin: -pi, end: pi);

  late ControlledAnimation slowRevolution;
  late ControlledAnimation mediumRevolution;
  late ControlledAnimation fastRevolution;

  @override
  void initState() {
    super.initState();

    void animationListener() {
      setState(() {});
    }

    slowRevolution = ControlledAnimation(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      ),
      animatable: rotationTween,
      listener: animationListener,
    );

    mediumRevolution = ControlledAnimation(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      ),
      animatable: rotationTween,
      listener: animationListener,
    );

    fastRevolution = ControlledAnimation(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
      animatable: rotationTween,
      listener: animationListener,
    );

    slowRevolution.controller.repeat();
    mediumRevolution.controller.repeat();
    fastRevolution.controller.repeat();
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
              slowRevolutionAngle: slowRevolution.animation.value,
              mediumRevolutionAngle: mediumRevolution.animation.value,
              fastRevolutionAngle: fastRevolution.animation.value,
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    slowRevolution.controller.dispose();
    mediumRevolution.controller.dispose();
    fastRevolution.controller.dispose();
    super.dispose();
  }
}

class BoardPainter extends CustomPainter {
  final ThemeData theme;
  final Board board;
  final double slowRevolutionAngle;
  final double mediumRevolutionAngle;
  final double fastRevolutionAngle;

  BoardPainter({
    required this.theme,
    required this.board,
    required this.slowRevolutionAngle,
    required this.mediumRevolutionAngle,
    required this.fastRevolutionAngle,
  });

  @override
  void paint(final Canvas canvas, final Size size) {
    final cellLength = size.width / board.width;
    drawGridSegments(size, canvas, cellLength);
    drawOrbs(canvas, size, cellLength);
  }

  void drawGridSegments(
    final Size size,
    final Canvas canvas,
    final double cellLength,
  ) {
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
    final orbRadius = cellLength / 8;

    void drawOrbs(
      final int cellRow,
      final int cellColumn,
      final int player,
      final int mass,
    ) {
      void drawOrb({
        required final double offsetFromCenter,
        final double revolutionOffset = 0,
      }) {
        final cellCenter = Offset(
          (cellColumn + 0.5) * cellLength,
          (cellRow + 0.5) * cellLength,
        );

        final criticalMass = board
            .cellTypeAt(cellRow: cellRow, cellColumn: cellColumn)
            .criticalMass;

        final angle = switch (criticalMass - mass) {
          1 => fastRevolutionAngle,
          2 => mediumRevolutionAngle,
          _ => slowRevolutionAngle,
        };

        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = playerColors[player];

        final orbCenter = Offset(
          cellCenter.dx - offsetFromCenter,
          cellCenter.dy,
        );

        final randomRevolutionOffset =
            Random(cellColumn * cellRow).nextDouble() * 2 * pi;

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

      if (mass == 1) {
        drawOrb(offsetFromCenter: orbRadius * 0.75);
      } else if (mass == 2) {
        final offsetFromCenter = orbRadius * 1.25;
        drawOrb(offsetFromCenter: offsetFromCenter);
        drawOrb(
          offsetFromCenter: offsetFromCenter,
          revolutionOffset: pi,
        );
      } else {
        final offsetFromCenter = orbRadius * 1.75;
        drawOrb(offsetFromCenter: offsetFromCenter);
        drawOrb(
          offsetFromCenter: offsetFromCenter,
          revolutionOffset: 2 * pi / 3,
        );
        drawOrb(
          offsetFromCenter: offsetFromCenter,
          revolutionOffset: 4 * pi / 3,
        );
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
  bool shouldRepaint(covariant final BoardPainter oldDelegate) {
    return oldDelegate.slowRevolutionAngle != slowRevolutionAngle;
  }
}
