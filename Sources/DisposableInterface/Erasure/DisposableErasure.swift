// MARK: - Disposable

extension Disposable {
    public func erase() -> AnyDisposable {
        AnyDisposable { await dispose() }
    }

    public func eraseToDisposable() -> AnyDisposable {
        erase()
    }
}
