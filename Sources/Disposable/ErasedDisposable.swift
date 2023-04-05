import Foundation
// MARK: - ErasedDisposable

public struct ErasedDisposable: Disposable, Sendable, Hashable, Identifiable {

  // MARK: Lifecycle

  public nonisolated init(_ disposable: some Disposable) {
    if let any = disposable as? ErasedDisposable {
      self = any
    } else if let auto = disposable as? AutoDisposable {
      self = auto.inner
    } else {
      self = .init {
        disposable.dispose()
      }
    }
  }

  public nonisolated init(disposal: @escaping () -> Void) {
    self.disposalAction = Locked(Action { disposal() })
    self.id = .init()
  }

  // MARK: Public

  public let id: UUID

  public nonisolated var isDisposed: Bool {
    disposalAction.value == nil
  }

  public static func == (lhs: ErasedDisposable, rhs: ErasedDisposable) -> Bool {
    lhs.id == rhs.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  public nonisolated func dispose() {
    let action = disposalAction.withLock { action in
      let current = action
      action = nil
      return current
    }
    if let action {
      action.run()
    }
  }

  // MARK: Private

  private struct Action: Sendable {
    init(_ action: @escaping @Sendable () -> Void) {
      self.action = action
    }

    let action: @Sendable () -> Void
    func run() {
      action()
    }
  }

  private let disposalAction: Locked<Action?>

}
