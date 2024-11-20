List<T> listWithMostElements<T>(List<List<T>> lists) {
  return lists.reduce(
      (current, next) => current.length >= next.length ? current : next);
}
