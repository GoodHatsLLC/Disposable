/// A `Disposable` conformer should cancel inflight work when `dispose()` is called.
public protocol Disposable {
  func dispose()
  func erase() -> AnyDisposable
}
