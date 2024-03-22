import 'package:flutter_test/flutter_test.dart';
import 'package:plutonium/logic/board.dart';
import 'package:plutonium/logic/cell.dart';
import 'package:plutonium/logic/cell_type.dart';
import 'package:plutonium/logic/matrix.dart';

void main() {
  test('Can create an empty board from size', () {
    final board = Board.ofSize(width: 1, height: 1);
    expect(board.width, 1);
    expect(board.height, 1);
    for (final row in board.cellMatrix) {
      for (final cell in row) {
        expect(cell, Cell(player: null, mass: 0));
      }
    }
  });

  test('Can create a board with a cell cellMatrix', () {
    final cellMatrix = [
      [Cell(player: 1, mass: 2), Cell(player: 2, mass: 2)],
      [Cell(player: 3, mass: 1), Cell(player: 4, mass: 1)],
    ];
    final board = Board(cellMatrix: cellMatrix);
    expect(board.width, 2);
    expect(board.height, 2);
    expect(board.cellMatrix, cellMatrix);
  });

  test('Can identify width correctly', () {
    final board = Board(cellMatrix: [
      [Cell(), Cell()],
      [Cell(), Cell()],
      [Cell(), Cell()],
    ]);
    expect(board.width, 2);
  });

  test('Can identify height correctly', () {
    final board = Board(cellMatrix: [
      [Cell(), Cell()],
      [Cell(), Cell()],
      [Cell(), Cell()],
    ]);
    expect(board.height, 3);
  });

  test('Can identify if the board is critical or not', () {
    final criticalBoard = Board(cellMatrix: [
      [
        Cell(player: 1, mass: 2),
        Cell(player: 2, mass: 3),
        Cell(player: 1, mass: 5),
      ],
    ]);
    expect(criticalBoard.critical, true);

    final nonCriticalBoard = Board(cellMatrix: [
      [Cell(), Cell(player: 1, mass: 1)],
    ]);
    expect(nonCriticalBoard.critical, false);
  });

  test('Can identify which players are still in the board', () {
    final board = Board(cellMatrix: [
      [Cell(player: 1, mass: 2), Cell(player: 3, mass: 3)],
      [Cell(), Cell(player: 3, mass: 4)],
    ]);
    expect(board.playersInBoard, {1, 3});
  });

  test('Can identify cell types correctly', () {
    final board = Board.ofSize(width: 3, height: 3);
    expect(board.cellTypeAt(cellColumn: 0, cellRow: 0), CellType.corner);
    expect(board.cellTypeAt(cellColumn: 1, cellRow: 0), CellType.edge);
    expect(board.cellTypeAt(cellColumn: 2, cellRow: 0), CellType.corner);
    expect(board.cellTypeAt(cellColumn: 0, cellRow: 1), CellType.edge);
    expect(board.cellTypeAt(cellColumn: 1, cellRow: 1), CellType.interior);
    expect(board.cellTypeAt(cellColumn: 2, cellRow: 1), CellType.edge);
    expect(board.cellTypeAt(cellColumn: 0, cellRow: 2), CellType.corner);
    expect(board.cellTypeAt(cellColumn: 1, cellRow: 2), CellType.edge);
    expect(board.cellTypeAt(cellColumn: 2, cellRow: 2), CellType.corner);
  });

  test('Can identify critical cells', () {
    final board = Board(cellMatrix: [
      [
        Cell(player: 1, mass: 2),
        Cell(player: 2, mass: 3),
        Cell(player: 1, mass: 5),
      ],
      [
        Cell(player: 2, mass: 4),
        Cell(player: 1, mass: 4),
        Cell(player: 2, mass: 1),
      ],
      [Cell(player: 1, mass: 1), Cell(player: 2, mass: 1), Cell(mass: 0)],
      [Cell(mass: 0), Cell(mass: 0), Cell(mass: 0)],
    ]);
    expect(board.criticalAt(cellRow: 0, cellColumn: 0), true);
    expect(board.criticalAt(cellRow: 0, cellColumn: 1), true);
    expect(board.criticalAt(cellRow: 0, cellColumn: 2), true);
    expect(board.criticalAt(cellRow: 1, cellColumn: 0), true);
    expect(board.criticalAt(cellRow: 1, cellColumn: 1), true);
    expect(board.criticalAt(cellRow: 1, cellColumn: 2), false);
    expect(board.criticalAt(cellRow: 2, cellColumn: 0), false);
    expect(board.criticalAt(cellRow: 2, cellColumn: 1), false);
    expect(board.criticalAt(cellRow: 2, cellColumn: 2), false);
    expect(board.criticalAt(cellRow: 3, cellColumn: 0), false);
    expect(board.criticalAt(cellRow: 3, cellColumn: 1), false);
    expect(board.criticalAt(cellRow: 3, cellColumn: 2), false);
  });

  test('Can play on an empty cell', () {
    final board = Board.ofSize(width: 2, height: 2);
    final newBoard = board.playedAt(cellRow: 1, cellColumn: 1, player: 1);
    var cellMatrix = newBoard.board.cellMatrix.toMatrix();
    expect(cellMatrix[0][0], Cell());
    expect(cellMatrix[0][1], Cell());
    expect(cellMatrix[1][0], Cell());
    expect(cellMatrix[1][1], Cell(player: 1, mass: 1));
  });

  test('Can play on a non-empty cell', () {
    final board = Board(cellMatrix: [
      [Cell(player: 1, mass: 1), Cell(player: 2, mass: 1)],
    ]);
    final newBoard = board.playedAt(cellRow: 0, cellColumn: 1, player: 2);
    var cellMatrix = newBoard.board.cellMatrix.toMatrix();
    expect(cellMatrix[0][0], Cell(player: 1, mass: 1));
    expect(cellMatrix[0][1], Cell(player: 2, mass: 2));
  });

  test(
      'Can calculate a single reaction step properly for a 3x3 board '
      'with critical mass at center', () {
    final board = Board(cellMatrix: [
      [
        Cell(player: 1, mass: 1),
        Cell(player: 1, mass: 1),
        Cell(player: 1, mass: 1),
      ],
      [
        Cell(player: 1, mass: 1),
        Cell(player: 1, mass: 4),
        Cell(player: 1, mass: 1),
      ],
      [
        Cell(player: 1, mass: 1),
        Cell(player: 1, mass: 1),
        Cell(player: 1, mass: 1),
      ],
    ]);
    final reactedBoard = board.reacted();
    final cellMatrix = reactedBoard.board.cellMatrix.toMatrix();
    expect(cellMatrix[0][0], Cell(player: 1, mass: 1));
    expect(cellMatrix[0][1], Cell(player: 1, mass: 2));
    expect(cellMatrix[0][2], Cell(player: 1, mass: 1));
    expect(cellMatrix[1][0], Cell(player: 1, mass: 2));
    expect(cellMatrix[1][1], Cell(mass: 0));
    expect(cellMatrix[1][2], Cell(player: 1, mass: 2));
    expect(cellMatrix[2][0], Cell(player: 1, mass: 1));
    expect(cellMatrix[2][1], Cell(player: 1, mass: 2));
    expect(cellMatrix[2][2], Cell(player: 1, mass: 1));

    final reactionMatrix = reactedBoard.reactionMatrix.toMatrix();
    expect(reactionMatrix[0][0], false);
    expect(reactionMatrix[0][1], false);
    expect(reactionMatrix[0][2], false);
    expect(reactionMatrix[1][0], false);
    expect(reactionMatrix[1][1], true);
    expect(reactionMatrix[1][2], false);
    expect(reactionMatrix[2][0], false);
    expect(reactionMatrix[2][1], false);
    expect(reactionMatrix[2][2], false);
  });

  test('Can calculate a single reaction step properly', () {
    final board = Board(cellMatrix: [
      [Cell(player: 1, mass: 2), Cell(player: 1, mass: 3)],
      [Cell(player: 1, mass: 1), Cell(player: 1, mass: 1)],
    ]);
    final reactedBoard = board.reacted();
    var cellMatrix = reactedBoard.board.cellMatrix.toMatrix();
    expect(cellMatrix[0][0], Cell(player: 1, mass: 1));
    expect(cellMatrix[0][1], Cell(player: 1, mass: 2));
    expect(cellMatrix[1][0], Cell(player: 1, mass: 2));
    expect(cellMatrix[1][1], Cell(player: 1, mass: 2));

    final reactionMatrix = reactedBoard.reactionMatrix.toMatrix();
    expect(reactionMatrix[0][0], true);
    expect(reactionMatrix[0][1], true);
    expect(reactionMatrix[1][0], false);
    expect(reactionMatrix[1][1], false);
  });

  test('Cannot create a board with negative width', () {
    expect(() => Board.ofSize(width: -1, height: 1),
        throwsA(isA<InvalidBoardSizeException>()));
  });

  test('Cannot create a board with  width of zero', () {
    expect(() => Board.ofSize(width: 0, height: 1),
        throwsA(isA<InvalidBoardSizeException>()));
  });

  test('Cannot create a board with negative height', () {
    expect(() => Board.ofSize(width: 1, height: -1),
        throwsA(isA<InvalidBoardSizeException>()));
  });

  test('Cannot create a board with height of zero', () {
    expect(() => Board.ofSize(width: 1, height: 0),
        throwsA(isA<InvalidBoardSizeException>()));
  });

  test('Cannot create a crooked board', () {
    expect(
        () => Board(cellMatrix: [
              [Cell(), Cell()],
              [Cell()],
            ]),
        throwsA(isA<CrookedBoardException>()));
  });

  test('Cannot play at a taken cell', () {
    final board = Board(cellMatrix: [
      [Cell(player: 1, mass: 1), Cell(player: 2, mass: 1)],
    ]);
    expect(() => board.playedAt(cellRow: 0, cellColumn: 1, player: 1),
        throwsA(isA<InvalidCellPlayerException>()));
  });

  test('Cannot play on a critical board', () {
    final board = Board(cellMatrix: [
      [Cell(player: 1, mass: 2), Cell(player: 2, mass: 3)],
    ]);
    expect(() => board.playedAt(cellRow: 0, cellColumn: 0, player: 1),
        throwsA(isA<MustReactFirstException>()));
  });

  test('Cannot react a non-critical board', () {
    final board = Board(cellMatrix: [
      [Cell(player: 1, mass: 1), Cell(player: 2, mass: 1)],
    ]);
    expect(() => board.reacted(), throwsA(isA<NothingToReactException>()));
  });
}