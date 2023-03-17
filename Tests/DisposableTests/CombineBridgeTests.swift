import Disposable
import XCTest

#if canImport(Combine)
import Combine

final class CombineBridgeTests: XCTestCase {

  /// This test just shows the other tests can actually work
  func test_cancellable_doesNotCancelUnexpectedly() async throws {
    var didFire = false
    let disposeStage = DisposableStage()

    AnyDisposable.make {
      AnyCancellable {
        didFire = true
      }
    }
    .stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
  }

  func test_cancellable_cancelsOnDeinit() throws {
    var didFire = false

    let run = {
      let disposeStage = DisposableStage()
      AnyDisposable.make {
        AnyCancellable {
          didFire = true
        }
      }
      .stage(on: disposeStage)
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposeStage)
    }
    run()
    XCTAssert(didFire)
  }

  func test_builder_cancellable_cancelsOnDispose() throws {
    var didFire = 0
    let disposeStage = DisposableStage()
    AnyDisposable.make {
      AnyCancellable {
        didFire += 1
      }
      [
        AnyCancellable {
          didFire += 1
        },
        AnyCancellable {
          didFire += 1
        },
      ]
      for _ in 0 ..< 20 {
        AnyCancellable {
          didFire += 1
        }
      }
    }
    .stage(on: disposeStage)
    XCTAssertEqual(didFire, 0)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    XCTAssertEqual(didFire, 23)
  }

  func test_cancellable_cancelsOnDispose() throws {
    var didFire = false
    let disposeStage = DisposableStage()
    AnyDisposable(
      AnyCancellable {
        didFire = true
      }
    )
    .stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    XCTAssert(didFire)
  }
}
#endif
