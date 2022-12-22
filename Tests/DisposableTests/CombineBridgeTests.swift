import Disposable
import XCTest

#if canImport(Combine)
import Combine

@MainActor
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

    func test_cancellable_cancelsOnDeinit() async throws {
        var didFire = false
        autoreleasepool {
            let disposeStage = DisposableStage()
            AnyCancellable {
                didFire = true
            }
            .erase()
            .stage(on: disposeStage)
            XCTAssertFalse(didFire)
            XCTAssertNotNil(disposeStage)
        }
        await Task.flush()
        XCTAssert(didFire)
    }

    func test_cancellable_cancelsOnDispose() async throws {
        var didFire = false
        let disposeStage = DisposableStage()
        AnyCancellable {
            didFire = true
        }
        .erase()
        .stage(on: disposeStage)
        XCTAssertFalse(didFire)
        XCTAssertNotNil(disposeStage)
        await disposeStage.dispose()
        XCTAssert(didFire)
    }
}
#endif
