
extension AnyDisposable {
  public init(_ task: Task<some Any, some Any>) {
    self.init {
      task.cancel()
    }
  }
}
