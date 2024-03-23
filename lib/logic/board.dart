import 'package:plutonium/logic/cell.dart';
import 'package:plutonium/logic/cell_type.dart';
import 'package:plutonium/logic/game_table.dart';
import 'package:plutonium/logic/matrix.dart';

class InvalidBoardSizeException extends FormatException {
  final int width;
  final int height;

  InvalidBoardSizeException({required this.width, required this.height})
      : super('Cannot create $width × $height board. '
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
  final UnmodifiableMatrix<Cell> cellMatrix;

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

  Iterable<int> get playersInBoard => Set.unmodifiable(cellMatrix
      .map((final row) => row.map((final cell) => cell.player))
      .expand((final cells) => cells)
      .nonNulls);

  Board({required this.cellMatrix}) {
    if (width < 1 || height < 1) {
      throw InvalidBoardSizeException(width: width, height: height);
    }

    for (final row in cellMatrix) {
      if (row.length != width) {
        throw CrookedBoardException(width: width, height: height);
      }
    }
  }

  Board.ofSize({required final int width, required final int height})
      : this(
            cellMatrix: [
          for (var cellRow = 0; cellRow < height; cellRow++)
            [for (var cellColumn = 0; cellColumn < width; cellColumn++) Cell()]
        ].toUnmodifiableMatrix());

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
    final cell = cellMatrix.toMatrix()[cellRow][cellColumn];
    final cellType = cellTypeAt(cellRow: cellRow, cellColumn: cellColumn);
    return cell.mass >= cellType.criticalMass;
  }

  UnreactedTable playedAt({
    required final int cellRow,
    required final int cellColumn,
    required final int player,
  }) {
    if (critical) {
      throw MustReactFirstException();
    }

    final oldCell = cellMatrix.toMatrix()[cellRow][cellColumn];
    final newCellMatrix = cellMatrix.toMatrix();

    if (oldCell.player != null && oldCell.player != player) {
      throw InvalidCellPlayerException(cell: oldCell, newPlayer: player);
    }
    newCellMatrix[cellRow][cellColumn] =
        Cell(player: player, mass: oldCell.mass + 1);
    return UnreactedTable(
        board: Board(cellMatrix: List.unmodifiable(newCellMatrix)));
  }

  ReactedTable reacted() {
    if (!critical) {
      throw NothingToReactException();
    }

    final newCellMatrix = cellMatrix.toMatrix();
    final reactionMatrix = [
      for (var cellRow = 0; cellRow < height; cellRow++)
        [for (var cellColumn = 0; cellColumn < width; cellColumn++) false]
    ];

    bool validCoordinate(
        {required final int cellRow, required final int cellColumn}) {
      return cellRow >= 0 &&
          cellRow < height &&
          cellColumn >= 0 &&
          cellColumn < width;
    }

    void react({required final int cellRow, required final int cellColumn}) {
      final adjacentCoordinates = [
        (cellRow, cellColumn - 1),
        (cellRow - 1, cellColumn),
        (cellRow, cellColumn + 1),
        (cellRow + 1, cellColumn),
      ];

      final oldCell = newCellMatrix[cellRow][cellColumn];
      final cellType = cellTypeAt(cellRow: cellRow, cellColumn: cellColumn);
      final newMass = oldCell.mass - cellType.criticalMass;
      newCellMatrix[cellRow][cellColumn] = Cell(
        player: newMass > 0 ? oldCell.player : null,
        mass: newMass,
      );
      reactionMatrix[cellRow][cellColumn] = true;

      for (final (adjacentRow, adjacentColumn) in adjacentCoordinates) {
        if (validCoordinate(cellRow: adjacentRow, cellColumn: adjacentColumn)) {
          final oldAdjacentCell = newCellMatrix[adjacentRow][adjacentColumn];
          newCellMatrix[adjacentRow][adjacentColumn] =
              Cell(player: oldCell.player, mass: oldAdjacentCell.mass + 1);
        }
      }
    }

    for (var cellRow = 0; cellRow < height; cellRow++) {
      for (var cellColumn = 0; cellColumn < width; cellColumn++) {
        if (criticalAt(cellRow: cellRow, cellColumn: cellColumn)) {
          react(cellRow: cellRow, cellColumn: cellColumn);
        }
      }
    }

    return ReactedTable(
      board: Board(cellMatrix: newCellMatrix.toUnmodifiableMatrix()),
      reactionMatrix: reactionMatrix.toUnmodifiableMatrix(),
    );
  }
}
