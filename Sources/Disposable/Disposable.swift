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
  nonisolated func auto() -> AutoDisposable
  nonisolated var isDisposed: Bool { get }
}

// MARK: - Disposable

extension Disposable {

  /// Erase the disposable to an ``AutoDisposable`` which disposes
  /// when it goes out of scope.
  public func auto() -> AutoDisposable {
    AutoDisposable(self)
  }

  public func erased() -> ErasedDisposable {
    ErasedDisposable(self)
  }
}

extension Disposable where Self == AutoDisposable {
  public func auto() -> AutoDisposable {
    AutoDisposable(self)
  }

  public func erased() -> ErasedDisposable {
    ErasedDisposable(self)
  }
}

extension Disposable where Self == ErasedDisposable {
  public func auto() -> AutoDisposable {
    AutoDisposable(self)
  }

  public func erased() -> ErasedDisposable {
    ErasedDisposable(self)
  }
}

// MARK: - Disposables

public enum Disposables { }

extension Disposables {
  public static func make(@DisposableBuilder builder: () -> ErasedDisposable) -> ErasedDisposable {
    builder()
  }
}
