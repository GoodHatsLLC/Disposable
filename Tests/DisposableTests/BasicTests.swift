import Disposable
import XCTest

// MARK: - BasicTests

final class BasicTests: XCTestCase {

  func test_disposable_firesOnDeinit() async throws {
    var didFire = false
    let run = {
      let disposable = AnyDisposable {
        didFire = true
      }
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
    }
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposable)
    disposable.dispose()
    XCTAssert(didFire)
  }
}
