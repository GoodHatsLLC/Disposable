// MARK: - DisposableBuilder

@resultBuilder
public enum DisposableBuilder {
  public static func buildExpression(_ disposable: some Disposable) -> [ErasedDisposable] {
    [ErasedDisposable(disposable)]
  }

  public static func buildExpression(_: ()) -> [ErasedDisposable] {
    []
  }

  public static func buildExpression(_ task: Task<some Any, some Any>) -> [ErasedDisposable] {
    [ErasedDisposable(task)]
  }

  public static func buildExpression(_ tasks: [Task<some Any, some Any>]) -> [ErasedDisposable] {
    tasks.map { ErasedDisposable($0) }
  }

  public static func buildPartialBlock(
    accumulated: [ErasedDisposable],
    next: [ErasedDisposable]
  ) -> [ErasedDisposable] {
    accumulated + next
  }

  public static func buildOptional(_ component: [ErasedDisposable]?) -> [ErasedDisposable] {
    component ?? []
  }

  public static func buildBlock(_ disposables: [ErasedDisposable] ...) -> [ErasedDisposable] {
    disposables.flatMap { $0 }
  }

  public static func buildArray(_ components: [[ErasedDisposable]]) -> [ErasedDisposable] {
    components.flatMap { $0 }
  }

  public static func buildFinalResult(_ disposables: [ErasedDisposable])
    -> ErasedDisposable
  {
    ErasedDisposable(disposal: {
      for disposable in disposables {
        disposable.dispose()
      }
    })
  }
}
