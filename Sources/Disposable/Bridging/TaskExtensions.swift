extension Task {
    @MainActor
    public func erase() -> AnyDisposable {
        AnyDisposable { self.cancel() }
    }
}
