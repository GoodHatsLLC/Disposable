// MARK: - Disposable

extension DisposableAsync {
  public func eraseAsync() -> AnyDisposableAsync {
    AnyDisposableAsync { await dispose() }
  }
}
