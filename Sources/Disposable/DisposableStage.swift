
import Foundation

// MARK: - DisposableStage

/// `DisposableStage` collects ``Disposable`` implementers, maintaining
/// their active work.
/// Staged disposables are disposed, ending their active work, on ``dispose()``.
///
/// - Disposal happens automatically if the `DisposableStage` is not retained.
/// - Staging a `Disposable` does not prevent it from being directly disposed
/// —only from automatic disposal.
/// - If a `Disposable` is staged on multiple stages they will be disposed
/// when any one stage is disposed.
public struct DisposableStage: Disposable, @unchecked Sendable {

  // MARK: Lifecycle

  public nonisolated init() {
    self.inner = .init()
  }

  // MARK: Public

  /// Stage a ``Disposable``to maintain any running work its a handle to.
  ///
  /// > Note:  If this stage has already been disposed, disposables passed in
  /// will be immediately disposed.
  public nonisolated func stage(
    _ disposable: some Disposable
  ) {
    inner.stage(disposable)
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

    init() {
      self.state = .init((false, []))
    }

    deinit {
      dispose()
    }

    // MARK: Internal

    func reset() {
      dispose()
      state.withLock { pair in
        pair = (false, [])
      }
    }

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

    func stage(_ disposable: some Disposable) {
      let disposeImmediately = state.withLock { pair in
        if !pair.isDisposed {
          pair.disposables.append(disposable.erase())
        }
        return pair.isDisposed
      }
      if disposeImmediately {
        disposable.dispose()
      }
    }

    // MARK: Private

    private let state: Locked<(isDisposed: Bool, disposables: [AnyDisposable])>

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
