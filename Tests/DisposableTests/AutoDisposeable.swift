import Disposable
import XCTest

// MARK: - AutoDisposeable

final class AutoDisposeable: XCTestCase {

  func test_autoDisposable_firesOnDeinit() async throws {
    var didFire = false
    let run = {
      let disposable = AutoDisposable {
        didFire = true
      }.auto()
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposable)
    }
    run()
    await Flush.tasks()
    XCTAssert(didFire)
  }

  func test_disposable_firesOnDispose() async throws {
    var didFire = false
    let disposable = AutoDisposable {
      didFire = true
    }.auto()
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposable)
    disposable.dispose()
    XCTAssert(didFire)
  }

  func test_autoDisposable_erasesToSelf() throws {
    // Erase should not change an already-auto value.
    let anyDisposable = AutoDisposable { }.auto()
    let anyDisposable2 = anyDisposable.auto()
    XCTAssert(anyDisposable == anyDisposable2)
  }

  func test_anyDisposable_erasesToSelf() throws {
    // Erase should not change an already-auto value.
    let anyDisposable = AutoDisposable { }.auto()
    let anyDisposable2 = anyDisposable.auto()
    XCTAssert(anyDisposable == anyDisposable2)
  }
}
