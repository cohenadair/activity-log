class ChangeListener<T> {
  List<T> _listeners = [];

  void add(T listener) {
    _listeners.add(listener);
  }

  void remove(T listener) {
    _listeners.remove(listener);
  }

  void notify(Function(T) callback) {
    _listeners.forEach((l) => callback(l));
  }
}