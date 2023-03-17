#if canImport(Combine)
import Combine
#endif

// MARK: - DisposableBuilder

@resultBuilder
public enum DisposableBuilder {
  public static func buildExpression(_ disposable: some Disposable) -> [AnyDisposable] {
    [AnyDisposable(disposable)]
  }

  #if canImport(Combine)
  public static func buildExpression(_ cancellable: some Cancellable) -> [AnyDisposable] {
    [AnyDisposable(cancellable)]
  }

  public static func buildExpression(_ cancellables: [any Cancellable]) -> [AnyDisposable] {
    cancellables.map { AnyDisposable($0) }
  }
  #endif

  public static func buildExpression(_: ()) -> [AnyDisposable] {
    []
  }

  public static func buildExpression(_ task: Task<some Any, some Any>) -> [AnyDisposable] {
    [AnyDisposable(task)]
  }

  public static func buildExpression(_ tasks: [Task<some Any, some Any>]) -> [AnyDisposable] {
    tasks.map { AnyDisposable($0) }
  }

  public static func buildPartialBlock(
    accumulated: [AnyDisposable],
    next: [AnyDisposable]
  ) -> [AnyDisposable] {
    accumulated + next
  }

  public static func buildOptional(_ component: [AnyDisposable]?) -> [AnyDisposable] {
    component ?? []
  }

  public static func buildBlock(_ disposables: [AnyDisposable] ...) -> [AnyDisposable] {
    disposables.flatMap { $0 }
  }

  public static func buildArray(_ components: [[AnyDisposable]]) -> [AnyDisposable] {
    components.flatMap { $0 }
  }

  public static func buildFinalResult(_ disposables: [AnyDisposable])
    -> AnyDisposable
  {
    AnyDisposable(disposal: {
      for disposable in disposables {
        disposable.dispose()
      }
    })
  }
}
