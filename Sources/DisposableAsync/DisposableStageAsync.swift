import DisposableAsyncInterface

// MARK: - DisposableAsyncStage

public final class DisposableAsyncStage: DisposableAsync {

  nonisolated public init() {}

  deinit {
    isDisposed = true
    asyncDisposables = []
  }

  public func stage(
    fileID _: String = #fileID,
    line _: Int = #line,
    column _: Int = #column,
    _ disposable: some DisposableAsync
  ) {
    if !isDisposed {
      asyncDisposables.append(disposable.eraseAsync())
    }
  }

  public func dispose() async {
    await asyncDispose()
  }

  /// End staged work and reset this stage to allow more.
  public func reset() async {
    isDisposed = false
    let copy = asyncDisposables
    asyncDisposables.removeAll()
    await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
      group.addTask {
        for d in copy {
          await d.dispose()
        }
      }
    }
  }

  public func erase() -> AnyDisposableAsync {
    AnyDisposableAsync {
      await self.dispose()
    }
  }

  private var isDisposed = false
  private var asyncDisposables: [AnyDisposableAsync] = []

  /// End staged work and disable this stage.
  private func asyncDispose() async {
    isDisposed = true
    let copy = asyncDisposables
    asyncDisposables.removeAll()
    await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
      for d in copy {
        group.addTask {
          await d.dispose()
        }
      }
    }
  }

}

extension DisposableAsync {

  public func stage(
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column,
    on stage: DisposableAsyncStage
  ) {
    stage.stage(fileID: fileID, line: line, column: column, self)
  }
}
