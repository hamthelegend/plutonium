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
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (criticalAt(x: x, y: y)) {
          return true;
        }
      }
    }
    return false;
  }

  Iterable<int> get playersInBoard => Set.unmodifiable(cellMatrix
      .map((row) => row.map((cell) => cell.player))
      .expand((cells) => cells)
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

  Board.ofSize({required int width, required int height})
      : this(
            cellMatrix: [
          for (var y = 0; y < height; y++)
            [for (var x = 0; x < width; x++) Cell()]
        ].toUnmodifiableMatrix());

  CellType cellTypeAt({required int x, required int y}) {
    final lastXIndex = width - 1;
    final lastYIndex = height - 1;
    var coordinates = (x, y);
    if (coordinates == (0, 0) ||
        coordinates == (0, lastYIndex) ||
        coordinates == (lastXIndex, 0) ||
        coordinates == (lastXIndex, lastYIndex)) {
      return CellType.corner;
    } else if (x == 0 || y == 0 || x == lastXIndex || y == lastYIndex) {
      return CellType.edge;
    } else {
      return CellType.interior;
    }
  }

  bool criticalAt({required int x, required int y}) {
    final cell = cellMatrix.toMatrix()[y][x];
    final cellType = cellTypeAt(x: x, y: y);
    return cell.mass >= cellType.criticalMass;
  }

  UnreactedTable playedAt(
      {required int x, required int y, required int player}) {
    if (critical) {
      throw MustReactFirstException();
    }

    final oldCell = cellMatrix.toMatrix()[y][x];
    final newCellMatrix =
        cellMatrix.map((row) => row.map((cell) => cell).toList()).toList();

    if (oldCell.player != null && oldCell.player != player) {
      throw InvalidCellPlayerException(cell: oldCell, newPlayer: player);
    }
    newCellMatrix[y][x] = Cell(player: player, mass: oldCell.mass + 1);
    return UnreactedTable(
        board: Board(cellMatrix: List.unmodifiable(newCellMatrix)));
  }

  ReactedTable reacted() {
    if (!critical) {
      throw NothingToReactException();
    }

    final newCellMatrix = cellMatrix.toMatrix();
    final reactionMatrix = [
      for (var y = 0; y < height; y++) [for (var x = 0; x < width; x++) false]
    ];

    bool validCoordinate({required int x, required int y}) {
      return x >= 0 && x < width && y >= 0 && y < height;
    }

    void react({required int x, required int y}) {
      final adjacentCoordinates = [
        (x - 1, y),
        (x, y - 1),
        (x + 1, y),
        (x, y + 1),
      ];

      final oldCell = newCellMatrix[y][x];
      final cellType = cellTypeAt(x: x, y: y);
      final newMass = oldCell.mass - cellType.criticalMass;
      newCellMatrix[y][x] = Cell(
        player: newMass > 0 ? oldCell.player : null,
        mass: newMass,
      );
      reactionMatrix[y][x] = true;

      for (final (adjacentX, adjacentY) in adjacentCoordinates) {
        if (validCoordinate(x: adjacentX, y: adjacentY)) {
          final oldAdjacentCell = newCellMatrix[adjacentY][adjacentX];
          newCellMatrix[adjacentY][adjacentX] =
              Cell(player: oldCell.player, mass: oldAdjacentCell.mass + 1);
        }
      }
    }

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < height; x++) {
        if (criticalAt(x: x, y: y)) {
          react(x: x, y: y);
        }
      }
    }

    return ReactedTable(
      board: Board(cellMatrix: newCellMatrix.toUnmodifiableMatrix()),
      reactionMatrix: reactionMatrix.toUnmodifiableMatrix(),
    );
  }
}
