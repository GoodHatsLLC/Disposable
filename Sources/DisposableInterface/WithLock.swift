import Foundation

extension NSLock {

  @discardableResult
  public func withLock<T>(_ act: () throws -> T) rethrows -> T {
    lock()
    let res = try act()
    unlock()
    return res
  }
}
