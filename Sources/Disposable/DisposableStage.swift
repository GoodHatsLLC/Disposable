
import Foundation

// MARK: - DisposableStage

/// `DisposableStage` collects ``Disposable`` implementers, maintaining
/// their active work.
/// Staged disposables are disposed, ending their active work, on ``dispose()``.
///
/// - Disposal happens automatically if the `DisposableStage` is not retained.
/// - Staging a `Disposable` does not prevent it from being directly disposed via ``dispose()``
/// —only from automatic disposal if it is an ``AutoDisposable``.
/// - If a `Disposable` is staged on multiple stages it will be disposed
/// when any one stage is disposed.
public struct DisposableStage: Disposable, @unchecked Sendable {

  // MARK: Lifecycle

  public nonisolated init() {
    self.inner = .init()
  }

  // MARK: Public

  /// Whether or not the stage is disposed.
  ///
  /// If not disposed it can be used to stage disposables.
  public var isDisposed: Bool {
    inner.isDisposed
  }

  /// Stage a ``Disposable``to maintain any running work its a handle to.
  ///
  /// > Warning:  If this stage has already been disposed, any passed disposable
  /// is immediately disposed. Use ``stageIfAvailable(_:)`` if this is unacceptable.
  public nonisolated func stage(
    _ disposable: some Disposable
  ) {
    inner.stage(disposable)
  }

  /// If this ``DisposableStage`` is itself not disposed, use it to stage a ``Disposable``
  /// to maintain any running work its a handle to.
  ///
  /// - Parameters:
  ///   - disposable: The disposable to store if possible.
  /// - Returns: Whether the disposable was stored.
  public nonisolated func stageIfAvailable(
    _ disposable: some Disposable
  )
    -> Bool
  {
    inner.stageIfAvailable(disposable)
  }

  /// End any staged ``Disposable`` work handles and reset this stage allowing further staging.
  public func reset() {
    inner.reset()
  }

  /// End any staged ``Disposable`` work handles and mark this stage as unusable.
  public func dispose() {
    inner.dispose()
  }

  // MARK: Private

  private final class Inner: Disposable {

    // MARK: Lifecycle

    @inline(__always)
    init() {
      self.state = .init((false, []))
    }

    @inline(__always)
    deinit {
      dispose()
    }

    // MARK: Internal

    @inline(__always) var isDisposed: Bool {
      state.value.isDisposed
    }

    @inline(__always)
    func reset() {
      dispose()
      state.withLock { pair in
        pair = (false, [])
      }
    }

    @inline(__always)
    func dispose() {
      let (isDisposed, disposables) = state.withLock { pair in
        let copy = pair
        pair = (true, [])
        return copy
      }
      if !isDisposed {
        for disposable in disposables {
          disposable.dispose()
        }
      }
    }

    @discardableResult
    @inline(__always)
    func stage(_ disposable: some Disposable) -> Bool {
      let stageIsDisposed = state.withLock { pair in
        if !pair.isDisposed {
          if let auto = disposable as? AutoDisposable {
            auto.take()
          }
          pair.disposables.append(disposable.erased())
        }
        return pair.isDisposed
      }
      if stageIsDisposed {
        disposable.dispose()
      }
      return !stageIsDisposed
    }

    @discardableResult
    @inline(__always)
    func stageIfAvailable(_ disposable: some Disposable) -> Bool {
      let stageIsDisposed = state.withLock { pair in
        if !pair.isDisposed {
          if let auto = disposable as? AutoDisposable {
            auto.take()
          }
          pair.disposables.append(disposable.erased())
        }
        return pair.isDisposed
      }
      return !stageIsDisposed
    }

    // MARK: Private

    private let state: Locked<(isDisposed: Bool, disposables: [ErasedDisposable])>

  }

  private let inner: Inner

}

extension Disposable {

  public func stage(
    on stage: DisposableStage
  ) {
    stage.stage(self)
  }
}
