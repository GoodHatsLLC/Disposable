// MARK: - Disposable

/// `Disposables` are handles to long running work.
/// Disposables should stop any remaining work as quickly as possible
/// when ``dispose()`` is called.
///
/// A disposable can be type-erased to ``AnyDisposable`` via ``dispose()``.
/// Disposal is automatically triggered on an ``AnyDisposable`` once it has no
/// remaining inbound references to it.
///
/// Disposables can be grouped together and stored with a ``DisposableStage``.
///
/// > Contract:
/// - `Disposable` implementors should cancel any long running work
/// when ``dispose()`` is called.
/// - Implementors should be `Sendable` and ensure ``dispose()``
/// can be safely used in a `nonisolated` context.
public protocol Disposable {
  nonisolated func dispose()
  nonisolated func erase() -> AnyDisposable
}

// MARK: - Disposable

extension Disposable {
  public func erase() -> AnyDisposable {
    AnyDisposable(self)
  }
}
