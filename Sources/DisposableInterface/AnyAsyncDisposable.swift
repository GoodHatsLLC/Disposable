// MARK: - AnyAsyncDisposable

/// A type-erased `Disposable`.
/// `AnyDisposable` triggers its disposalAction on `deinit`
public final class AnyAsyncDisposable: AsyncDisposable {

    public init(_ disposalAction: @escaping () async -> Void) {
        disposeActor = .init { await disposalAction() }
    }

    deinit {
        let disposeActor = disposeActor
        Task {
            await disposeActor.dispose()
        }
    }

    public func dispose() async {
        guard !isDisposed
        else {
            return
        }
        isDisposed = true
        await disposeActor.dispose()
    }

    public func erase() -> AnyAsyncDisposable {
        self
    }

    private actor DisposableActor {
        init(_ disposalAction: @escaping () async -> Void) {
            self.disposalAction = disposalAction
        }

        func dispose() async {
            if !isDisposed {
                isDisposed = true
                await disposalAction()
            }
        }

        private let disposalAction: () async -> Void
        private var isDisposed = false
    }


    private let disposeActor: DisposableActor
    private var isDisposed = false
}

// MARK: Hashable

extension AnyAsyncDisposable: Hashable {
    nonisolated public static func == (lhs: AnyAsyncDisposable, rhs: AnyAsyncDisposable) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

#if canImport(Combine)
import Combine

extension AnyAsyncDisposable: Cancellable {
    public func cancel() {
        sync().dispose()
    }
}
#endif
