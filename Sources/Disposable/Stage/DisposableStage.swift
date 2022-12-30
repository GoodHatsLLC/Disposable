import DisposableInterface
import Foundation

// MARK: - DisposableStage

public final class DisposableStage: Disposable {

  nonisolated public init() {}

  deinit {
    isDisposed = true
    disposables = []
  }

  public func stage(
    fileID _: String = #fileID,
    line _: Int = #line,
    column _: Int = #column,
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
    isDisposed = false
    let syncCopy = disposables
    disposables.removeAll()
    for sync in syncCopy {
      sync.dispose()
    }
  }

  private var isDisposed = false
  private var disposables: [AnyDisposable] = []

  private func syncDispose() {
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
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column,
    on stage: DisposableStage
  ) {
    stage.stage(fileID: fileID, line: line, column: column, self)
  }
}
