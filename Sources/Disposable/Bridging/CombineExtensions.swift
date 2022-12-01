#if canImport(Combine)
import Combine

extension AnyCancellable: Disposable {
    public func dispose() {
        cancel()
    }
}

extension Combine.Cancellable {
    @_disfavoredOverload
    @MainActor
    public func erase() -> AnyDisposable {
        AnyDisposable { self.cancel() }
    }
}
#endif
