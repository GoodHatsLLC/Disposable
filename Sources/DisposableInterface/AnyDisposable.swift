import Foundation

// MARK: - AnyDisposable

/// A type-erased `Disposable`.
/// `AnyDisposable` triggers its disposalAction on `deinit`
public final class AnyDisposable: Disposable, @unchecked
Sendable {

  public init(_ disposalAction: @escaping () -> Void) {
    self.disposalAction = disposalAction
  }

  deinit {
    dispose()
  }

  public func dispose() {
    lock.lock()
    defer { lock.unlock() }
    if !isDisposed {
      isDisposed = true
      disposalAction()
    }
  }

  public func erase() -> AnyDisposable {
    self
  }

  private let lock = NSLock()

  private let disposalAction: () -> Void
  private var isDisposed = false

}

// MARK: Hashable

extension AnyDisposable: Hashable {
  nonisolated public static func == (lhs: AnyDisposable, rhs: AnyDisposable) -> Bool {
    ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
  }

  nonisolated public func hash(into hasher: inout Hasher) {
    hasher.combine(ObjectIdentifier(self))
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
