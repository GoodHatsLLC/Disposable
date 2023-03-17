// MARK: - AnyDisposable

public struct AnyDisposable: Disposable, Sendable, Hashable {

  // MARK: Lifecycle

  public nonisolated init(_ disposable: some Disposable) {
    if let any = disposable as? AnyDisposable {
      self = any
    } else {
      self.inner = Inner {
        disposable.dispose()
      }
    }
  }

  public nonisolated init(disposal: @escaping () -> Void) {
    self.inner = Inner {
      disposal()
    }
  }

  // MARK: Public

  public nonisolated var isDisposed: Bool {
    inner.isDisposed
  }

  public static func == (lhs: AnyDisposable, rhs: AnyDisposable) -> Bool {
    ObjectIdentifier(lhs.inner) == ObjectIdentifier(rhs.inner)
  }

  public nonisolated static func make(@DisposableBuilder builder: () -> AnyDisposable)
    -> AnyDisposable
  {
    builder()
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(inner))
  }

  public nonisolated func dispose() {
    inner.dispose()
  }

  public nonisolated func erase() -> AnyDisposable {
    self
  }

  // MARK: Private

  private final class Inner: Sendable {

    // MARK: Lifecycle

    nonisolated init(_ disposalAction: @escaping @Sendable () -> Void) {
      self.disposalAction = Locked(Action(disposalAction))
    }

    deinit {
      dispose()
    }

    // MARK: Internal

    nonisolated var isDisposed: Bool {
      disposalAction.value == nil
    }

    nonisolated func dispose() {
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

  private let inner: Inner

}
