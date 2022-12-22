#if canImport(Combine)
import Combine

extension AnyCancellable: AsyncDisposable {
    public func dispose() {
        cancel()
    }
}

extension Combine.Cancellable {
    @_disfavoredOverload
    public func erase() -> AnyDisposable {
        AnyDisposable { self.cancel() }
    }
}
#endif
