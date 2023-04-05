#if canImport(Combine)
import Combine

extension ErasedDisposable {
  public init(_ cancellable: Cancellable) {
    self.init {
      cancellable.cancel()
    }
  }
}

#endif
