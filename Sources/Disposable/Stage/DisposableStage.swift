import DisposableInterface
import Foundation

// MARK: - DisposableStage

public final class DisposableStage: Disposable, @unchecked
Sendable {

  nonisolated public init() {}

  deinit {
    dispose()
  }

  public func stage(
    _ disposable: some Disposable
  ) {
    let shouldDispose = lock.withLock {
      let shouldStage = !isDisposed
      if shouldStage {
        disposables.append(disposable.erase())
      }
      return !shouldStage
    }
    if shouldDispose {
      disposable.dispose()
    }
  }

  /// End staged work and reset this stage to allow more.
  public func reset() {
    let actions = lock.withLock {
      self.isDisposed = false
      let copy = self.disposables
      self.disposables = []
      return copy
    }

    for disposable in actions {
      disposable.dispose()
    }
  }

  public func dispose() {
    let copy: [AnyDisposable] = lock
      .withLock {
        let returnValue = isDisposed
          ? []
          : self.disposables
        self.isDisposed = true
        self.disposables = []
        return returnValue
      }
    for disposable in copy {
      disposable.dispose()
    }
  }

  private var isDisposed = false
  private var disposables: [AnyDisposable] = []
  private let lock = NSLock()

}

extension Disposable {

  public func stage(
    on stage: DisposableStage
  ) {
    stage.stage(self)
  }
}
