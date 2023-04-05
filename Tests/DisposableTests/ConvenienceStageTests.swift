import Disposable
import XCTest

// MARK: - ConvenienceStageTests

final class ConvenienceStageTests: XCTestCase {

  // MARK: stageByIdentity

  func test_stageByIdentity_diposesOnRestage() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    .stageByIdentity(token: "LOL")
    XCTAssertFalse(didFire)

    AutoDisposable { }.stageByIdentity(token: "LOL")

    // The two stage keys are the same so the second
    // staged disposable replaces the first and the first
    // is executed when deallocated.
    XCTAssert(didFire)
  }

  func test_stageByIdentity_doesNotDisposeForOtherIdentifier() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    .stageByIdentity(token: "LOL")

    XCTAssertFalse(didFire)
    AutoDisposable { }
      .stageByIdentity(token: "ROFL")

    // The two stage keys are different so the initially
    // staged disposable is never called.
    XCTAssertFalse(didFire)
  }

  func test_stageByIdentity_resets() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    .stageByIdentity(token: "LOL")
    XCTAssertFalse(didFire)

    Disposables.stages.resetIdentityStage()

    // The two stage keys are the same so the second
    // staged disposable replaces the first and the first
    // is executed when deallocated.
    XCTAssert(didFire)
  }

  // MARK: stageIndefinitely

  func test_stageIndefinitely_acceptsMultiple() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    .stageIndefinitely()

    XCTAssertFalse(didFire)
    AutoDisposable { }
      .stageIndefinitely()

    // The two stage keys are different so the initially
    // staged disposable is never called.
    XCTAssertFalse(didFire)
  }

  func test_stageIndefinitely_resets() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    .stageIndefinitely()

    XCTAssertFalse(didFire)
    Disposables.stages.resetIndefiniteStage()

    // The two stage keys are different so the initially
    // staged disposable is never called.
    XCTAssert(didFire)
  }

  // MARK: stageByUniqueCallsite

  func test_stageByUniqueCallsite_notDispose_onCallAtOtherLocation() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    // Line A
    .stageByUniqueCallSite()
    XCTAssertFalse(didFire)
    AutoDisposable { }
      // Line B
      .stageByUniqueCallSite()

    // Line A and Line B are separate source locations
    // and so separate stage keys, so A's disposable is
    // not called.
    XCTAssertFalse(didFire)
  }

  func test_stageByUniqueCallsite_resets() async throws {
    var didFire = false
    AutoDisposable {
      didFire = true
    }
    .stageByUniqueCallSite()
    XCTAssertFalse(didFire)

    Disposables.stages.resetCallSiteStage()

    // Line A and Line B are separate source locations
    // and so separate stage keys, so A's disposable is
    // not called.
    XCTAssert(didFire)
  }

}
