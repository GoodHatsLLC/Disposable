// MARK: - Disposable

extension Disposable {
    public func erase() -> AnyDisposable {
        AnyDisposable { dispose() }
    }

    public func eraseToDisposable() -> AnyDisposable {
        erase()
    }
}
