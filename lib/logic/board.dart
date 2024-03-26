import 'dart:collection';

import 'package:plutonium/logic/cell.dart';
import 'package:plutonium/logic/cell_type.dart';
import 'package:plutonium/logic/change.dart';
import 'package:plutonium/logic/matrix.dart';

class InvalidBoardSizeException extends FormatException {
  final int height;
  final int width;

  InvalidBoardSizeException({required this.height, required this.width})
      : super('Cannot create $height × $width board. '
            'Board must be at least 1 × 1.');
}

class CrookedBoardException extends FormatException {
  final int width;
  final int height;

  CrookedBoardException({required this.width, required this.height})
      : super('Cannot create $width × $height board. '
            'All rows must have the same length.');
}

class InvalidCellPlayerException extends FormatException {
  final Cell cell;
  final int newPlayer;

  InvalidCellPlayerException({required this.cell, required this.newPlayer})
      : super('Player $newPlayer cannot play in this cell $cell. '
            "It's already taken by player ${cell.player}");
}

class MustReactFirstException extends FormatException {
  MustReactFirstException() : super('You must react the board before playing.');
}

class NothingToReactException extends FormatException {
  NothingToReactException()
      : super('There are no critical cells in the board.');
}

class Board {
  final UnmodifiableMatrixView<Cell> cellMatrix;

  final UnmodifiableMatrixView<Change> changeMatrix;

  int get width => cellMatrix.firstOrNull?.length ?? 0;

  int get height => cellMatrix.length;

  bool get critical {
    for (var cellRow = 0; cellRow < height; cellRow++) {
      for (var cellColumn = 0; cellColumn < width; cellColumn++) {
        if (criticalAt(cellRow: cellRow, cellColumn: cellColumn)) {
          return true;
        }
      }
    }
    return false;
  }

  UnmodifiableSetView<int> get playersInBoard => UnmodifiableSetView(cellMatrix
      .map((final row) => row.map((final cell) => cell.player))
      .expand((final cells) => cells)
      .nonNulls
      .toSet());

  static void _checkSize({
    required final int height,
    required final int width,
  }) {
    if (height < 1 || width < 1) {
      throw InvalidBoardSizeException(height: height, width: width);
    }
  }

  Board._({required this.cellMatrix, required this.changeMatrix}) {
    for (final row in cellMatrix) {
      if (row.length != width) {
        throw CrookedBoardException(height: height, width: width);
      }
    }
  }

  factory Board({
    required final UnmodifiableMatrixView<Cell> cellMatrix,
    final UnmodifiableMatrixView<Change>? changeMatrix,
  }) {
    final height = cellMatrix.length;
    final width = cellMatrix.firstOrNull?.length ?? 0;

    _checkSize(height: height, width: width);

    return Board._(
      cellMatrix: cellMatrix,
      changeMatrix: changeMatrix ??
          generateMatrix(height, width, (final index) => Change.none)
              .toUnmodifiableMatrixView(),
    );
  }

  factory Board.ofSize({required final int height, required final int width}) {
    _checkSize(height: height, width: width);

    return Board(
      cellMatrix: generateMatrix(height, width, (final index) => Cell())
          .toUnmodifiableMatrixView(),
    );
  }

  CellType cellTypeAt({
    required final int cellRow,
    required final int cellColumn,
  }) {
    final lastRowIndex = height - 1;
    final lastColumnIndex = width - 1;
    final coordinates = (cellRow, cellColumn);
    if (coordinates == (0, 0) ||
        coordinates == (0, lastColumnIndex) ||
        coordinates == (lastRowIndex, 0) ||
        coordinates == (lastRowIndex, lastColumnIndex)) {
      return CellType.corner;
    } else if (cellRow == 0 ||
        cellColumn == 0 ||
        cellRow == lastRowIndex ||
        cellColumn == lastColumnIndex) {
      return CellType.edge;
    } else {
      return CellType.interior;
    }
  }

  bool criticalAt({required final int cellRow, required final int cellColumn}) {
    final cell = cellMatrix[cellRow][cellColumn];
    final cellType = cellTypeAt(cellRow: cellRow, cellColumn: cellColumn);
    return cell.mass >= cellType.criticalMass;
  }

  Board playedAt({
    required final int cellRow,
    required final int cellColumn,
    required final int player,
  }) {
    if (critical) {
      throw MustReactFirstException();
    }

    final oldCell = cellMatrix[cellRow][cellColumn];
    final newCellMatrix = cellMatrix.toMatrix();

    if (oldCell.player != null && oldCell.player != player) {
      throw InvalidCellPlayerException(cell: oldCell, newPlayer: player);
    }

    newCellMatrix[cellRow][cellColumn] =
        Cell(player: player, mass: oldCell.mass + 1);

    final changeMatrix =
        generateMatrix(height, width, (final index) => Change.none);
    changeMatrix[cellRow][cellColumn] = Change.materialization;

    return Board(
      cellMatrix: newCellMatrix.toUnmodifiableMatrixView(),
      changeMatrix: changeMatrix.toUnmodifiableMatrixView(),
    );
  }

  Board reacted() {
    if (!critical) {
      throw NothingToReactException();
    }

    final newCellMatrix = cellMatrix.toMatrix();
    final newChangeMatrix =
        generateMatrix(height, width, (final index) => Change.none);

    for (var cellRow = 0; cellRow < height; cellRow++) {
      for (var cellColumn = 0; cellColumn < width; cellColumn++) {
        if (criticalAt(cellRow: cellRow, cellColumn: cellColumn)) {
          _react(
            cellMatrix: newCellMatrix,
            changeMatrix: newChangeMatrix,
            cellRow: cellRow,
            cellColumn: cellColumn,
          );
        }
      }
    }

    return Board(
      cellMatrix: newCellMatrix.toUnmodifiableMatrixView(),
      changeMatrix: newChangeMatrix.toUnmodifiableMatrixView(),
    );
  }

  void _react({
    required final Matrix<Cell> cellMatrix,
    required final Matrix<Change> changeMatrix,
    required final int cellRow,
    required final int cellColumn,
  }) {
    final adjacentCoordinates = [
      (cellRow, cellColumn - 1),
      (cellRow - 1, cellColumn),
      (cellRow, cellColumn + 1),
      (cellRow + 1, cellColumn),
    ];

    final oldCell = cellMatrix[cellRow][cellColumn];
    final cellType = cellTypeAt(cellRow: cellRow, cellColumn: cellColumn);
    final newMass = oldCell.mass - cellType.criticalMass;

    cellMatrix[cellRow][cellColumn] = Cell(
      player: newMass > 0 ? oldCell.player : null,
      mass: newMass,
    );

    changeMatrix[cellRow][cellColumn] = Change.fission;

    for (final (adjacentRow, adjacentColumn) in adjacentCoordinates) {
      if (_isValidCoordinate(
          cellRow: adjacentRow, cellColumn: adjacentColumn)) {
        final oldAdjacentCell = cellMatrix[adjacentRow][adjacentColumn];
        cellMatrix[adjacentRow][adjacentColumn] =
            Cell(player: oldCell.player, mass: oldAdjacentCell.mass + 1);
      }
    }
  }

  bool _isValidCoordinate({
    required final int cellRow,
    required final int cellColumn,
  }) {
    return cellRow >= 0 &&
        cellRow < height &&
        cellColumn >= 0 &&
        cellColumn < width;
  }
}
