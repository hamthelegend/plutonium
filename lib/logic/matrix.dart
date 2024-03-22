typedef Matrix<T> = List<List<T>>;

typedef UnmodifiableMatrix<T> = Iterable<Iterable<T>>;

extension Immutability<T> on Matrix<T> {
  UnmodifiableMatrix<T> toUnmodifiableMatrix() {
    return List<List<T>>.unmodifiable(
        map((final row) => List<T>.unmodifiable(row)));
  }
}

extension Mutability<T> on UnmodifiableMatrix<T> {
  Matrix<T> toMatrix() => map((final row) => row.toList()).toList();
}
