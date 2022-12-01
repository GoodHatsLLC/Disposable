import Disposable
import XCTest

// MARK: - ErasureTests

@MainActor
final class ErasureTests: XCTestCase {

  func test_erasedDisposable_firesOnDeinit() async throws {
    var didFire = false
    autoreleasepool {
      let disposable = AnyDisposable {
        didFire = true
      }.erase()
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
    }.erase()
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposable)
    await disposable.dispose()
    XCTAssert(didFire)
  }

  func test_anyDisposable_erasesToSelf() throws {
    // Erase should not change a pre-erased value.
    let anyDisposable = AnyDisposable {}.erase()
    let anyDisposable2 = anyDisposable.erase()
    XCTAssert(anyDisposable === anyDisposable2)
  }
}
