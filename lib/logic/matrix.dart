import 'dart:collection';

typedef Matrix<E> = List<List<E>>;

typedef UnmodifiableMatrixView<E>
    = UnmodifiableListView<UnmodifiableListView<E>>;

extension Immutability<E> on Matrix<E> {
  UnmodifiableMatrixView<E> toUnmodifiableMatrixView() {
    return UnmodifiableListView(map((e) => UnmodifiableListView(e)));
  }
}

extension Mutability<E> on UnmodifiableMatrixView<E> {
  Matrix<E> toMatrix() => map((final row) => row.toList()).toList();
}

Matrix<E> generateMatrix<E>(
  final int height,
  final int width,
  final E Function(int index) generator, {
  final bool growable = true,
}) {
  return List.generate(
    height,
    (final index) => List.generate(width, generator),
  );
}
