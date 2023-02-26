import Foundation

// MARK: - AnyDisposable

public struct AnyDisposable: Disposable, Sendable {

  public func dispose() {
    impl.dispose()
  }

  private let impl: AnyDisposableImpl
  public init<D: Disposable>(_ disposable: D) {
    if let any = disposable as? AnyDisposable {
      self = any
    } else {
      impl = AnyDisposableImpl {
        disposable.dispose()
      }
    }
  }

  public init(_ disposable: AnyDisposable) {
    self = disposable
  }

  public init(_ disposalAction: @escaping () -> Void) {
    impl = AnyDisposableImpl {
      disposalAction()
    }
  }

  public func erase() -> AnyDisposable {
    self
  }
}

// MARK: - AnyDisposableImpl

private final class AnyDisposableImpl: @unchecked
Sendable {

  public init(_ disposalAction: @escaping () -> Void) {
    self.disposalAction = disposalAction
  }

  deinit {
    dispose()
  }

  public func dispose() {
    let action = lock
      .withLock {
        let action = disposalAction
        disposalAction = nil
        return action
      }
    action?()
  }

  private let lock = NSLock()
  private var disposalAction: (() -> Void)?

}

// MARK: - AnyDisposable + Hashable

extension AnyDisposable: Hashable {
  nonisolated public static func == (lhs: AnyDisposable, rhs: AnyDisposable) -> Bool {
    ObjectIdentifier(lhs.impl) == ObjectIdentifier(rhs.impl)
  }

  nonisolated public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(impl))
  }
}

#if canImport(Combine)
import Combine

extension AnyDisposable: Cancellable {
  public func cancel() {
    dispose()
  }
}
#endif
