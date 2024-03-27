import 'dart:collection';

import 'package:plutonium/logic/board.dart';

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
  final Board board;

  UnmodifiableListView<int> get playersInPlay => UnmodifiableListView([
        for (var player = 0; player < playerCount; player++)
          if ((round == 0 && player >= currentPlayer) ||
              board.playersInBoard.contains(player))
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
    required this.board,
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
    required final Board board,
  }) {
    final state = GameState(
      round: round,
      currentPlayer: currentPlayer,
      playerCount: playerCount,
      board: board,
    );
    final GameState(:playersInPlay) = state;

    if (!playersInPlay.contains(currentPlayer)) {
      var correctedPlayer = currentPlayer;
      while (!playersInPlay.contains(correctedPlayer)) {
        correctedPlayer = (correctedPlayer + 1) % playerCount;
      }

      return GameState(
        round: round,
        currentPlayer: correctedPlayer,
        playerCount: playerCount,
        board: board,
      );
    }

    return state;
  }

  factory GameState.ofSize({
    required final int playerCount,
    required final int boardHeight,
    required final int boardWidth,
  }) {
    return GameState(
      playerCount: playerCount,
      board: Board.ofSize(height: boardHeight, width: boardWidth),
    );
  }

  GameState playedAt({
    required final int cellRow,
    required final int cellColumn,
  }) {
    try {
      final newBoard = board.playedAt(
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
        board: newBoard,
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
      board: board.reacted(),
    );
  }
}
