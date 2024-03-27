import 'dart:math';

import 'package:flutter/material.dart';
import 'package:plutonium/constants.dart';
import 'package:plutonium/logic/board.dart';
import 'package:plutonium/ui/util/animation/controlled_animation.dart';

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

  late AnimationController orbitAnimationController;
  late ControlledAnimation materializationAnimation;
  Board? board;

  @override
  void initState() {
    super.initState();

    void animationListener() {
      setState(() {});
    }

    orbitAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )
      ..addListener(animationListener)
      ..repeat();

    materializationAnimation = ControlledAnimation(
      controller: AnimationController(
        vsync: this,
        duration: materializationAnimationSpeed,
      ),
      animatable: Tween(begin: 0.0, end: 1.0),
    )..animation.addListener(animationListener);
  }

  @override
  Widget build(final BuildContext context) {
    if (widget.board != board) {
      materializationAnimation.controller.reset();
      materializationAnimation.controller.forward();
      board = widget.board;
    }

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
              orbitProgress: orbitAnimationController.value,
              materializationProgress: materializationAnimation.animation.value,
            ),
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    orbitAnimationController.dispose();
    materializationAnimation.controller.dispose();
    super.dispose();
  }
}
