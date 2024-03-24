import 'dart:collection';

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

  UnmodifiableListView<int> get playersInPlay => UnmodifiableListView([
        for (var player = 0; player < playerCount; player++)
          if ((round == 0 && player >= currentPlayer) ||
              table.board.playersInBoard.contains(player))
            player,
      ]);

  int get nextPlayer {
    final nextPlayerIndex = playersInPlay.indexOf(currentPlayer) + 1;
    return playersInPlay[nextPlayerIndex % playersInPlay.length];
  }

  int? get winner => playersInPlay.singleOrNull;

  bool get gameOver => winner != null;

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

  factory GameState.withCorrectedCurrentPlayer({
    final int round = 0,
    final int currentPlayer = 0,
    required final int playerCount,
    required final GameTable table,
  }) {
    final state = GameState(
      round: round,
      currentPlayer: currentPlayer,
      playerCount: playerCount,
      table: table,
    );

    if (!state.playersInPlay.contains(state.currentPlayer)) {
      var correctedPlayer = state.currentPlayer;
      while (!state.playersInPlay.contains(correctedPlayer)) {
        correctedPlayer = (correctedPlayer + 1) % state.playerCount;
      }

      return GameState(
        round: round,
        currentPlayer: correctedPlayer,
        playerCount: playerCount,
        table: table,
      );
    }

    return state;
  }

  factory GameState.ofSize({
    required final int playerCount,
    required final int boardWidth,
    required final int boardHeight,
  }) {
    return GameState(
      playerCount: playerCount,
      table: UnreactedTable(
          board: Board.ofSize(width: boardWidth, height: boardHeight)),
    );
  }

  GameState playedAt({
    required final int cellRow,
    required final int cellColumn,
  }) {
    try {
      final newBoard = table.board.playedAt(
        cellRow: cellRow,
        cellColumn: cellColumn,
        player: currentPlayer,
      );
      final newCurrentPlayer = (currentPlayer + 1) % playerCount;
      final newRound = newCurrentPlayer == 0 ? round + 1 : round;
      return GameState.withCorrectedCurrentPlayer(
        round: newRound,
        currentPlayer: nextPlayer,
        playerCount: playerCount,
        table: newBoard,
      );
    } on InvalidCellPlayerException {
      return this;
    }
  }

  GameState reacted() {
    return GameState.withCorrectedCurrentPlayer(
      round: round,
      currentPlayer: currentPlayer,
      playerCount: playerCount,
      table: table.board.reacted(),
    );
  }
}
