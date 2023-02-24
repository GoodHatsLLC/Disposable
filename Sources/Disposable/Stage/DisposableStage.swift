import DisposableInterface
import Foundation

// MARK: - DisposableStage

public final class DisposableStage: Disposable, @unchecked
Sendable {

  nonisolated public init() {}

  deinit {
    syncDispose()
  }

  public func stage(
    _ disposable: some Disposable
  ) {
    if !isDisposed {
      disposables.append(disposable.erase())
    }
  }

  public func dispose() {
    syncDispose()
  }

  /// End staged work and reset this stage to allow more.
  public func reset() {
    lock.lock()

    isDisposed = false
    let syncCopy = disposables
    disposables.removeAll()

    lock.unlock()

    for sync in syncCopy {
      sync.dispose()
    }
  }

  private var isDisposed = false
  private var disposables: [AnyDisposable] = []
  private let lock = NSLock()

  private func syncDispose() {
    lock.lock()
    defer { lock.unlock() }
    isDisposed = true
    let syncDisposables = disposables
    disposables.removeAll()
    for disposable in syncDisposables {
      disposable.dispose()
    }
  }

}

extension Disposable {

  public func stage(
    on stage: DisposableStage
  ) {
    stage.stage(self)
  }
}
