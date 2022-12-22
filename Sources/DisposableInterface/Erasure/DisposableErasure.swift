// MARK: - Disposable

extension AsyncDisposable {
    public func erase() -> AnyAsyncDisposable {
        AnyAsyncDisposable { await dispose() }
    }
}

extension Disposable {
    public func erase() -> AnyDisposable {
        AnyDisposable { dispose() }
    }
}
