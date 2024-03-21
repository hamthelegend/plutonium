import 'package:flutter/material.dart';

const playerCounts = [2, 3, 4, 5, 6, 7, 8];

enum BoardSize {
  small(label: "Small", width: 6, height: 11),
  large(label: "Large", width: 10, height: 19);

  final String label;
  final int width;
  final int height;

  const BoardSize({
    required this.label,
    required this.width,
    required this.height,
  });
}

const playerColors = [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
  Colors.pink,
];