import 'dart:async';

import 'package:plutonium/logic/game_state.dart';
import 'package:rxdart/rxdart.dart';

import '../constants.dart';

class Game {
  final _stateBehaviorSubject = BehaviorSubject<GameState>();

  Stream<GameState> get state =>
      _stateBehaviorSubject.stream.asBroadcastStream();

  Timer? timer;

  Game({
    required final int playerCount,
    required final int boardHeight,
    required final int boardWidth,
  }) {
    _stateBehaviorSubject.add(GameState.ofSize(
      playerCount: playerCount,
      boardHeight: boardHeight,
      boardWidth: boardWidth,
    ));
  }

  void restart() {
    final oldState = _stateBehaviorSubject.value;
    final newState = GameState.ofSize(
      playerCount: oldState.playerCount,
      boardHeight: oldState.board.height,
      boardWidth: oldState.board.width,
    );
    _stateBehaviorSubject.add(newState);
  }

  void play({required final int cellRow, required final int cellColumn}) {
    final newState = _stateBehaviorSubject.value
        .playedAt(cellRow: cellRow, cellColumn: cellColumn);
    _stateBehaviorSubject.add(newState);
    _react();
  }

  void _react() {
    timer?.cancel();
    timer = Timer.periodic(fissionAnimationSpeed, (final timer) {
      final state = _stateBehaviorSubject.value;
      if (state.board.critical) {
        _stateBehaviorSubject.add(state.reacted());
      } else {
        timer.cancel();
      }
    });
  }
}
