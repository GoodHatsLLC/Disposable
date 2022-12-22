import Disposable
import XCTest

// MARK: - DisposalStageTests

@MainActor
final class DisposalStageTests: XCTestCase {

    func test_disposalStage_abortsOnDeinit() async throws {
        var didFire = false
        autoreleasepool {
            let disposeStage = DisposableStage()
            AnyDisposable {
                didFire = true
            }.stage(on: disposeStage)
            XCTAssertFalse(didFire)
            XCTAssertNotNil(disposeStage)
        }
        await Task.flush()
        XCTAssert(didFire)
    }

    func test_disposalStage_abortsOnDispose() async throws {
        var didFire = false
        let disposeStage = DisposableStage()
        AnyDisposable {
            didFire = true
        }.stage(on: disposeStage)
        XCTAssertFalse(didFire)
        XCTAssertNotNil(disposeStage)
        await disposeStage.dispose()
        XCTAssert(didFire)
    }

}
