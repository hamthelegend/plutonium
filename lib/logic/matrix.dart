import 'dart:collection';

typedef Matrix<T> = List<List<T>>;

typedef UnmodifiableMatrixView<T> = UnmodifiableListView<UnmodifiableListView<T>>;

extension Immutability<T> on Matrix<T> {
  UnmodifiableMatrixView<T> toUnmodifiableMatrixView() {
    return UnmodifiableListView(map((e) => UnmodifiableListView(e)));
  }
}

extension Mutability<T> on UnmodifiableMatrixView<T> {
  Matrix<T> toMatrix() => map((final row) => row.toList()).toList();
}
