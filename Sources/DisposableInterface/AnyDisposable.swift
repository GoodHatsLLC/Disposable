// MARK: - AnyDisposable

/// `AnyDisposable` triggers its disposalAction on `deinit`
@MainActor
public final class AnyDisposable: Disposable {

    public init(_ disposalAction: @escaping () -> Void) {
        self.disposalAction = disposalAction
    }

    deinit {
        guard !isDisposed
        else {
            return
        }
        disposalAction()
    }

    public func dispose() {
        guard !isDisposed
        else {
            return
        }
        isDisposed = true
        disposalAction()
    }

    public func eraseToDisposable() -> AnyDisposable {
        erase()
    }

    public func erase() -> AnyDisposable {
        self
    }

    private let disposalAction: () -> Void
    private var isDisposed = false
}

// MARK: Hashable

extension AnyDisposable: Hashable {
    nonisolated public static func == (lhs: AnyDisposable, rhs: AnyDisposable) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
