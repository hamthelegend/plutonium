import 'board.dart';
import 'matrix.dart';

sealed class GameTable {
  final Board board;

  GameTable({required this.board});
}

class UnreactedTable extends GameTable {

  UnreactedTable({required super.board});
}

class ReactedTable extends GameTable {
  final UnmodifiableMatrix<bool> reactionMatrix;

  ReactedTable({required super.board, required this.reactionMatrix});
}