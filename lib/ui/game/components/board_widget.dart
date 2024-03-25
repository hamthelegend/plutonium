import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plutonium/logic/board.dart';

import 'board_painter.dart';

class BoardWidget extends StatefulWidget {
  final Board board;
  final void Function({
    required int cellColumn,
    required int cellRow,
  }) onPlayedAt;

  const BoardWidget({super.key, required this.board, required this.onPlayedAt});

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget>
    with TickerProviderStateMixin {
  final rotationTween = Tween(begin: -pi, end: pi);

  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    void animationListener() {
      setState(() {});
    }

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )
      ..addListener(animationListener);

    animationController.repeat();
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
              animationProgress: animationController.value,
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}