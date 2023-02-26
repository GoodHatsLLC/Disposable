// MARK: - Disposable

extension Disposable {
  public func erase() -> AnyDisposable {
    AnyDisposable(self)
  }
}
