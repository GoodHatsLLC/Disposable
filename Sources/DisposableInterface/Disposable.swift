/// A `Disposable` conformer should cancel inflight work when `dispose()` is called.
public protocol Disposable {
  nonisolated func dispose()
  nonisolated func erase() -> AnyDisposable
}
