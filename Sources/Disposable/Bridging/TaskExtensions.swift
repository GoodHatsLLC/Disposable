extension ErasedDisposable {
  public init(_ task: Task<some Any, some Error>) {
    self.init {
      task.cancel()
    }
  }
}
