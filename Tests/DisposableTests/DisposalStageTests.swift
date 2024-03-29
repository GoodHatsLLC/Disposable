import Disposable
import XCTest

// MARK: - DisposalStageTests

final class DisposalStageTests: XCTestCase {

  func test_disposalStage_abortsOnDeinit() throws {
    var didFire = false
    let run = {
      let disposeStage = DisposableStage()
      AutoDisposable {
        didFire = true
      }.stage(on: disposeStage)
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposeStage)
    }
    run()

    XCTAssert(didFire)
  }

  func test_disposalStage_abortsOnDispose() throws {
    var didFire = false
    let disposeStage = DisposableStage()
    AutoDisposable {
      didFire = true
    }.stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    XCTAssert(didFire)
  }

}
