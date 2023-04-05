
// MARK: - AutoDisposable

/// An AutoDisposable will ``dispose()`` automatically once deallocated unless
/// its ownership is first removed with ``take()`` or it is staged on a ``DisposableStage``.
///
/// Whether or not the AutoDisposable will auto-dispose can be tested with ``hasOwnership``.
public struct AutoDisposable: Disposable, Sendable, Hashable {

  // MARK: Lifecycle

  public nonisolated init(disposal: @escaping () -> Void) {
    self.init(ErasedDisposable(disposal: disposal))
  }

  public nonisolated init(_ disposable: some Disposable) {
    if let disp = disposable as? AutoDisposable {
      self.init(disp)
    } else if let disp = disposable as? ErasedDisposable {
      self.init(disp)
    } else {
      self.init(ErasedDisposable(disposable))
    }
  }

  public nonisolated init(_ disposable: AutoDisposable) {
    self = disposable
  }

  public nonisolated init(_ disposable: ErasedDisposable) {
    let inner = disposable
    self.inner = inner
    self.deinitAction = .init(action: { inner.dispose() })
  }

  // MARK: Public

  public var isDisposed: Bool {
    inner.isDisposed
  }

  /// Whether the AutoDisposable still has ownership — and so will actually auto-dispose when
  /// deallocated.
  public var hasOwnership: Bool {
    deinitAction.willAutoDispose
  }

  public static func == (lhs: AutoDisposable, rhs: AutoDisposable) -> Bool {
    lhs.inner == rhs
      .inner && ObjectIdentifier(lhs.deinitAction) == ObjectIdentifier(lhs.deinitAction)
  }

  public static func == (lhs: AutoDisposable, rhs: ErasedDisposable) -> Bool {
    lhs.inner == rhs
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(inner)
  }

  public func dispose() {
    inner.dispose()
  }

  /// Take the AutoDisposable's ownership.
  public func take() {
    deinitAction.take()
  }

  // MARK: Internal

  let inner: ErasedDisposable

  // MARK: Private

  private final class DeinitAction: Sendable {

    // MARK: Lifecycle

    init(action: @escaping @Sendable () -> Void) {
      self.action = .init(action)
    }

    deinit {
      action.value?()
    }

    // MARK: Internal

    var willAutoDispose: Bool {
      action.value != nil
    }

    func take() {
      action.value = nil
    }

    // MARK: Private

    private let action: Locked < (@Sendable () -> Void)?>

  }

  private let deinitAction: DeinitAction

}
