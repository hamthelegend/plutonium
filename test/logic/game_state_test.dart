import 'package:flutter_test/flutter_test.dart';
import 'package:plutonium/logic/board.dart';
import 'package:plutonium/logic/cell.dart';
import 'package:plutonium/logic/game_state.dart';
import 'package:plutonium/logic/game_table.dart';
import 'package:plutonium/logic/matrix.dart';

void main() {
  test('Can create a new state from size', () {
    final state = GameState.ofSize(
      playerCount: 2,
      boardWidth: 3,
      boardHeight: 3,
    );
    expect(state.round, 0);
    expect(state.currentPlayer, 0);
    expect(state.playerCount, 2);
    expect(state.table.board.width, 3);
    expect(state.table.board.height, 3);
  });

  test('Can create a board with all the parameters specified', () {
    final board = Board.ofSize(width: 3, height: 3);
    final state = GameState(
      round: 3,
      currentPlayer: 7,
      playerCount: 9,
      table: UnreactedTable(board: board),
    );
    expect(state.round, 3);
    expect(state.currentPlayer, 7);
    expect(state.playerCount, 9);
    expect(state.table.board, board);
  });

  test('Can create a board with corrected current player', () {
    final state = GameState.withCorrectedCurrentPlayer(
      round: 1,
      currentPlayer: 1,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1), Cell(player: 2, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(state.currentPlayer, 2);
  });

  test('Can play a move', () {
    final state = GameState.ofSize(
      playerCount: 2,
      boardWidth: 3,
      boardHeight: 3,
    );
    final newGame = state.playedAt(cellRow: 1, cellColumn: 1);
    expect(newGame.round, 0);
    expect(newGame.currentPlayer, 1);
    expect(newGame.playerCount, 2);
    expect(newGame.table.board.width, 3);
    expect(newGame.table.board.cellMatrix[1][1].mass, 1);
  });

  test('Can reset the current player when everyone has already played', () {
    final state = GameState(
      playerCount: 2,
      table: UnreactedTable(
        board: Board.ofSize(width: 3, height: 3),
      ),
    );
    final newGame = state
        .playedAt(cellRow: 0, cellColumn: 0)
        .playedAt(cellRow: 1, cellColumn: 1);
    expect(newGame.currentPlayer, 0);
  });

  test('Can up the round when everyone has already played', () {
    final state = GameState(
      currentPlayer: 1,
      playerCount: 2,
      table: UnreactedTable(
        board: Board.ofSize(width: 3, height: 3),
      ),
    );
    final newGame = state.playedAt(cellRow: 1, cellColumn: 1);
    expect(newGame.round, 1);
  });

  test('Can react a board', () {
    final state = GameState(
        playerCount: 3,
        table: UnreactedTable(
          board: Board(
              cellMatrix: [
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
          ].toUnmodifiableMatrixView()),
        ));
    final reactedGame = state.reacted();
    final table = reactedGame.table as ReactedTable;
    expect(table.reactionMatrix[0][0], true);
  });

  test('Everyone can play on game start', () {
    final state = GameState(
      playerCount: 2,
      table: UnreactedTable(board: Board.ofSize(width: 2, height: 2)),
    );
    expect(state.playersInPlay, [0, 1]);
  });

  test('Players not in board after round zero can no longer play', () {
    final state = GameState(
      round: 2,
      currentPlayer: 0,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1), Cell(player: 2, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(state.playersInPlay, [0, 2]);
  });

  test('Players immediately eliminated in round zero can no longer play', () {
    final state = GameState(
      round: 0,
      currentPlayer: 2,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1), Cell(player: 2, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(state.playersInPlay, [0, 2]);
  });

  test('Can identify the winner', () {
    final state = GameState(
      round: 3,
      currentPlayer: 2,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(state.winner, 0);
  });

  test('Can identify that there are no winners', () {
    final state = GameState(
      round: 0,
      currentPlayer: 2,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1), Cell(player: 2, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(state.winner, null);
  });

  test('Can identify if the game is over', () {
    final gameOverState = GameState(
      round: 3,
      currentPlayer: 2,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(gameOverState.gameOver, true);

    final notOverState = GameState(
      round: 0,
      currentPlayer: 2,
      playerCount: 3,
      table: UnreactedTable(
        board: Board(
          cellMatrix: [
            [Cell(player: 0, mass: 1), Cell(player: 2, mass: 1)],
          ].toUnmodifiableMatrixView(),
        ),
      ),
    );
    expect(notOverState.gameOver, false);
  });

  test('Cannot create a state with a negative round', () {
    expect(
      () => GameState(
        round: -1,
        currentPlayer: 0,
        playerCount: 2,
        table: UnreactedTable(board: Board.ofSize(width: 1, height: 1)),
      ),
      throwsA(isA<InvalidRoundException>()),
    );
  });

  test('Cannot create a state with less than 2 players', () {
    expect(
      () => GameState(
        round: 0,
        currentPlayer: 0,
        playerCount: 1,
        table: UnreactedTable(board: Board.ofSize(width: 1, height: 1)),
      ),
      throwsA(isA<InvalidPlayerCountException>()),
    );
  });

  test('Cannot create a state with a negative current player', () {
    expect(
      () => GameState(
        round: 0,
        currentPlayer: -1,
        playerCount: 2,
        table: UnreactedTable(board: Board.ofSize(width: 1, height: 1)),
      ),
      throwsA(isA<InvalidCurrentPlayerException>()),
    );
  });

  test(
      'Cannot create a state with a current player '
      'greater than the player count', () {
    expect(
      () => GameState(
        round: 0,
        currentPlayer: 2,
        playerCount: 2,
        table: UnreactedTable(board: Board.ofSize(width: 1, height: 1)),
      ),
      throwsA(isA<InvalidCurrentPlayerException>()),
    );
  });

  test('Cannot play a move on a critical board', () {
    final state = GameState(
        playerCount: 3,
        table: UnreactedTable(
          board: Board(
              cellMatrix: [
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
          ].toUnmodifiableMatrixView()),
        ));
    expect(
      () => state.playedAt(cellRow: 1, cellColumn: 1),
      throwsA(isA<MustReactFirstException>()),
    );
  });

  test('Cannot play a move on a taken cell', () {
    final state = GameState(
        currentPlayer: 1,
        playerCount: 2,
        table: UnreactedTable(
          board: Board(
              cellMatrix: [
            [Cell(player: 0, mass: 1), Cell()],
            [Cell(), Cell()],
          ].toUnmodifiableMatrixView()),
        ));
    final playedGame = state.playedAt(cellRow: 0, cellColumn: 0);
    expect(state, playedGame);
  });
}
