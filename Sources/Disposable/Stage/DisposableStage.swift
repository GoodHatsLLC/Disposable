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
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column,
    _ disposable: some Disposable
  ) {
    if !isDisposed {
      disposables.append(disposable.erase())
    } else {
      LogHooks.log(
        DisposedStageError(
          file: fileID,
          line: line,
          column: column
        )
      )
    }
  }

  /// End staged work and disable this stage.
  public func dispose() async {
    var copy: [AnyDisposable] = []
    isDisposed = true
    copy = disposables
    disposables.removeAll()
    await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
      for d in copy {
        group.addTask {
          await d.dispose()
        }
      }
    }
  }

  /// End staged work and reset this stage to allow more.
  public func reset() async {
    isDisposed = false
    let copy = disposables
    disposables.removeAll()
    await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
      group.addTask {
        for d in copy {
          await d.dispose()
        }
      }
    }
  }

  private var isDisposed = false
  private var disposables: [AnyDisposable] = []

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
