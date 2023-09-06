extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) whereFunction) =>
      map((items) => items.where(whereFunction).toList());
}