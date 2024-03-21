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

  test('Can play a move', () {
    final state = GameState.ofSize(
      playerCount: 2,
      boardWidth: 3,
      boardHeight: 3,
    );
    final newGame = state.playedAt(x: 1, y: 1);
    expect(newGame.round, 0);
    expect(newGame.currentPlayer, 1);
    expect(newGame.playerCount, 2);
    expect(newGame.table.board.width, 3);
    expect(newGame.table.board.cellMatrix.toMatrix()[1][1].mass, 1);
  });

  test('Can reset the current player when everyone has already played', () {
    final state = GameState(
      currentPlayer: 1,
      playerCount: 2,
      table: UnreactedTable(
        board: Board.ofSize(width: 3, height: 3),
      ),
    );
    final newGame = state.playedAt(x: 1, y: 1);
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
    final newGame = state.playedAt(x: 1, y: 1);
    expect(newGame.round, 1);
  });

  test('Can react a board', () {
    final state = GameState(
        playerCount: 3,
        table: UnreactedTable(
          board: Board(cellMatrix: [
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
          ]),
        ));
    final reactedGame = state.reacted();
    final table = reactedGame.table as ReactedTable;
    expect(table.reactionMatrix.toMatrix()[0][0], true);
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
          board: Board(cellMatrix: [
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
            [Cell(player: 0, mass: 3), Cell(player: 0, mass: 3)],
          ]),
        ));
    expect(
      () => state.playedAt(x: 1, y: 1),
      throwsA(isA<MustReactFirstException>()),
    );
  });

  test('Cannot play a move on a taken cell', () {
    final state = GameState(
        currentPlayer: 1,
        playerCount: 2,
        table: UnreactedTable(
          board: Board(cellMatrix: [
            [Cell(player: 0, mass: 1), Cell()],
            [Cell(), Cell()],
          ]),
        ));
    final playedGame = state.playedAt(x: 0, y: 0);
    expect(state, playedGame);
  });
}
