import 'package:plutonium/logic/board.dart';
import 'package:plutonium/logic/game_table.dart';

class InvalidRoundException extends FormatException {
  final int round;

  InvalidRoundException({required this.round})
      : super('A game cannot have a round $round. '
            'Round should be >= 0.');
}

class InvalidCurrentPlayerException extends FormatException {
  final int playerCount;
  final int currentPlayer;

  InvalidCurrentPlayerException({
    required this.playerCount,
    required this.currentPlayer,
  }) : super('Player $currentPlayer cannot play '
            'in a game with $playerCount players.');
}

class InvalidPlayerCountException extends FormatException {
  final int playerCount;

  InvalidPlayerCountException({required this.playerCount})
      : super('Cannot start a game with $playerCount players. '
            'You need at least 2 players.');
}

class GameState {
  final int round;
  final int currentPlayer;
  final int playerCount;
  final GameTable table;

  GameState({
    this.round = 0,
    this.currentPlayer = 0,
    required this.playerCount,
    required this.table,
  }) {
    if (round < 0) {
      throw InvalidRoundException(round: round);
    }
    if (playerCount < 2) {
      throw InvalidPlayerCountException(playerCount: playerCount);
    }
    if (currentPlayer >= playerCount || currentPlayer < 0) {
      throw InvalidCurrentPlayerException(
        playerCount: playerCount,
        currentPlayer: currentPlayer,
      );
    }
  }

  GameState.ofSize({
    required int playerCount,
    required int boardWidth,
    required int boardHeight,
  }) : this(
          playerCount: playerCount,
          table: UnreactedTable(
              board: Board.ofSize(width: boardWidth, height: boardHeight)),
        );

  GameState playedAt({required int x, required int y}) {
    try {
      final newBoard = table.board.playedAt(x: x, y: y, player: currentPlayer);
      final newCurrentPlayer = (currentPlayer + 1) % playerCount;
      final newRound = newCurrentPlayer == 0 ? round + 1 : round;
      return GameState(
        round: newRound,
        currentPlayer: newCurrentPlayer,
        playerCount: playerCount,
        table: newBoard,
      );
    } on InvalidCellPlayerException {
      return this;
    }
  }

  GameState reacted() {
    return GameState(
      round: round,
      currentPlayer: currentPlayer,
      playerCount: playerCount,
      table: table.board.reacted(),
    );
  }
}
