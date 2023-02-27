import Disposable
import XCTest

#if canImport(Combine)
import Combine

final class CombineBridgeTests: XCTestCase {

  // This test just shows the other tests can actually work
  func test_cancellable_doesNotCancelUnexpectedly() throws {
    var didFire = false
    let disposeStage = DisposableStage()
    AnyCancellable {
      didFire = true
    }
    .erase()
    .stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
  }

  func test_cancellable_cancelsOnDeinit() throws {
    var didFire = false {
      let disposeStage = DisposableStage()
      AnyCancellable {
        didFire = true
      }
      .erase()
      .stage(on: disposeStage)
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposeStage)
    }
    XCTAssert(didFire)
  }

  func test_cancellable_cancelsOnDispose() throws {
    var didFire = false
    let disposeStage = DisposableStage()
    AnyCancellable {
      didFire = true
    }
    .erase()
    .stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    XCTAssert(didFire)
  }
}
#endif
