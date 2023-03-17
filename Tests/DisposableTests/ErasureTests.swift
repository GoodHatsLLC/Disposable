import Disposable
import XCTest

// MARK: - ErasureTests

final class ErasureTests: XCTestCase {

  func test_erasedDisposable_firesOnDeinit() async throws {
    var didFire = false
    let run = {
      let disposable = AnyDisposable {
        didFire = true
      }.erase()
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposable)
    }
    run()
    await Flush.tasks()
    XCTAssert(didFire)
  }

  func test_disposable_firesOnDispose() async throws {
    var didFire = false
    let disposable = AnyDisposable {
      didFire = true
    }.erase()
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposable)
    disposable.dispose()
    XCTAssert(didFire)
  }

  func test_anyDisposable_erasesToSelf() throws {
    // Erase should not change a pre-erased value.
    let anyDisposable = AnyDisposable { }.erase()
    let anyDisposable2 = anyDisposable.erase()
    XCTAssert(anyDisposable == anyDisposable2)
  }
}
