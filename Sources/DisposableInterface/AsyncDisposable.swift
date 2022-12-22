// MARK: - AsyncDisposable

/// A `Disposable` conformer should cancel inflight work when `dispose()` is called.
public protocol AsyncDisposable {
    func dispose() async
}

extension AsyncDisposable {
    public func sync() -> AnyDisposable {
        AnyDisposable { Task { await dispose() } }
    }
}

// MARK: - Disposable

/// A `Disposable` conformer should cancel inflight work when `dispose()` is called.
public protocol Disposable {
    func dispose()
    func erase() -> AnyDisposable
}
