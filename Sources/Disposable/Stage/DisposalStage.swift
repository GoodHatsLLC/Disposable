import DisposableInterface
import Foundation

// MARK: - DisposalStage

@MainActor
public final class DisposalStage: Disposable {

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
    public func dispose() {
        var copy: [AnyDisposable] = []
        isDisposed = true
        copy = disposables
        disposables.removeAll()

        for d in copy {
            d.dispose()
        }
    }

    /// End staged work and reset this stage to allow more.
    public func reset() {
        var copy: [AnyDisposable] = []
        isDisposed = false
        copy = disposables
        disposables.removeAll()

        for d in copy {
            d.dispose()
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
        on stage: DisposalStage
    ) {
        stage.stage(fileID: fileID, line: line, column: column, self)
    }
}
