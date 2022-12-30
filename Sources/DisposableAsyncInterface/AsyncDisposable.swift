// MARK: - Disposable

/// A `Disposable` conformer should cancel inflight work when `dispose()` is called.
public protocol DisposableAsync {
  func dispose() async
  func erase() -> AnyDisposableAsync
}
