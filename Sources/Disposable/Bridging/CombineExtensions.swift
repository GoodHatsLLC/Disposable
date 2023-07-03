#if canImport(Combine)
import Combine

extension ErasedDisposable {
  public init(_ cancellable: some Combine.Cancellable) {
    self.init {
      cancellable.cancel()
    }
  }
}

extension DisposableBuilder {
  public static func buildExpression(
    _ cancellable: some Combine
      .Cancellable
  ) -> [ErasedDisposable] {
    [ErasedDisposable(cancellable)]
  }

  public static func buildExpression(_ cancellables: [any Combine.Cancellable])
    -> [ErasedDisposable]
  {
    cancellables.map { ErasedDisposable($0) }
  }
}
#endif
