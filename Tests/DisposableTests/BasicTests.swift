import Disposable
import XCTest

// MARK: - BasicTests

@MainActor
final class BasicTests: XCTestCase {

  func test_disposable_firesOnDeinit() async throws {
    var didFire = false
    autoreleasepool {
      let disposable = AnyDisposable {
        didFire = true
      }
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposable)
    }
    await Task.flush()
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
