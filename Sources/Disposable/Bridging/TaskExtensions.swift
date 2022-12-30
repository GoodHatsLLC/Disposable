import DisposableInterface

extension Task {
  public func erase() -> AnyDisposable {
    AnyDisposable { self.cancel() }
  }
}
