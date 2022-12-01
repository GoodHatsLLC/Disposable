// MARK: - Disposable

/// A `Disposable` conformer should cancel inflight work when `dispose()` is called.
@MainActor
public protocol Disposable {
    func dispose()
}
