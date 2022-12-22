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

    public func stage(
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        _ disposable: some AsyncDisposable
    ) {
        if !isDisposed {
            disposables.append(disposable.sync())
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

    public func dispose() {
        syncDispose()
        Task { await asyncDispose() }
    }

    public func dispose() async {
        syncDispose()
        await asyncDispose()
    }

    public func syncReset() {
        isDisposed = false
        let syncCopy = disposables
        disposables.removeAll()
        for sync in syncCopy {
            sync.dispose()
        }
        let copy = asyncDisposables
        asyncDisposables.removeAll()
        Task {
            await withThrowingTaskGroup(of: Void.self, returning: Void.self) { group in
                group.addTask {
                    for d in copy {
                        await d.dispose()
                    }
                }
            }
        }
    }

    /// End staged work and reset this stage to allow more.
    public func reset() async {
        isDisposed = false
        let syncCopy = disposables
        disposables.removeAll()
        for sync in syncCopy {
            sync.dispose()
        }
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

    private var isDisposed = false
    private var asyncDisposables: [AnyAsyncDisposable] = []
    private var disposables: [AnyDisposable] = []

    private func syncDispose() {
        isDisposed = true
        let syncDisposables = disposables
        disposables.removeAll()
        for disposable in syncDisposables {
            disposable.dispose()
        }
    }

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

extension AsyncDisposable {

    public func stage(
        fileID: String = #fileID,
        line: Int = #line,
        column: Int = #column,
        on stage: DisposableStage
    ) {
        stage.stage(fileID: fileID, line: line, column: column, self)
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
