import Disposable
import XCTest

// MARK: - DisposalStageTests

@MainActor
final class DisposalStageTests: XCTestCase {

  func test_disposalStage_abortsOnDeinit() throws {
    var didFire = false
    autoreleasepool {
      let disposeStage = DisposableStage()
      AnyDisposable {
        didFire = true
      }.stage(on: disposeStage)
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposeStage)
    }
    XCTAssert(didFire)
  }

  func test_disposalStage_abortsOnDispose() throws {
    var didFire = false
    let disposeStage = DisposableStage()
    AnyDisposable {
      didFire = true
    }.stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    XCTAssert(didFire)
  }

}
