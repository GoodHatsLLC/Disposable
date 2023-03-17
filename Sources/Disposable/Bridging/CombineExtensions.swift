#if canImport(Combine)
import Combine

extension AnyDisposable {
  public init(_ cancellable: Cancellable) {
    self.init {
      cancellable.cancel()
    }
  }
}

#endif
