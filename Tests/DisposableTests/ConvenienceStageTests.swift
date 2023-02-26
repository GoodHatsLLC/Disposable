import Disposable
import XCTest

// MARK: - ConvenienceStageTests

final class ConvenienceStageTests: XCTestCase {

  func test_stageOne_disposesOnRestage() async throws {
    var didFire = false
    AnyDisposable {
      didFire = true
    }
    .stageOne(by: "LOL")
    XCTAssertFalse(didFire)

    AnyDisposable {}.stageOne(by: "LOL")

    // The two stage keys are the same so the second
    // staged disposable replaces the first and the first
    // is executed when deallocated.
    XCTAssert(didFire)
  }

  func test_stageOne_doesNotDisposesForOtherIdentifier() async throws {
    var didFire = false
    AnyDisposable {
      didFire = true
    }
    .stageOne(by: "LOL")

    XCTAssertFalse(didFire)
    AnyDisposable {}
      .stageOne(by: "ROFL")

    // The two stage keys are different so the initially
    // staged disposable is never called.
    XCTAssertFalse(didFire)
  }

  func test_stageOne_doesNotDispose_onCallAtOtherLocation() async throws {
    var didFire = false
    AnyDisposable {
      didFire = true
    }
    // Line A
    .stageOneByLocation()
    XCTAssertFalse(didFire)
    AnyDisposable {}
      // Line B
      .stageOneByLocation()

    // Line A and Line B are separate source locations
    // and so separate stage keys, so A's disposable is
    // not called.
    XCTAssertFalse(didFire)
  }

}
