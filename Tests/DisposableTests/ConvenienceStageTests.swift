import Disposable
import XCTest

// MARK: - ConvenienceStageTests

@MainActor
final class ConvenienceStageTests: XCTestCase {

    func test_stageOne_disposesOnRestage() async throws {
        var didFire = false
        await AnyDisposable {
            didFire = true
        }
        .stageOne(by: "LOL")
        XCTAssertFalse(didFire)

        await AnyDisposable {}.stageOne(by: "LOL")

        // The two stage keys are the same so the second
        // staged disposable replaces the first and the first
        // is executed when deallocated.
        XCTAssert(didFire)
    }

    func test_stageOne_doesNotDisposesForOtherIdentifier() async throws {
        var didFire = false
        await AnyDisposable {
            didFire = true
        }
        .stageOne(by: "LOL")

        XCTAssertFalse(didFire)
        await AnyDisposable {}
            .stageOne(by: "ROFL")

        // The two stage keys are different so the initially
        // staged disposable is never called.
        XCTAssertFalse(didFire)
    }

    func test_stageOne_doesNotDispose_onCallAtOtherLocation() async throws {
        var didFire = false
        await AnyDisposable {
            didFire = true
        }
        // Line A
        .stageOneByLocation()
        XCTAssertFalse(didFire)
        await AnyDisposable {}
            // Line B
            .stageOneByLocation()

        // Line A and Line B are separate source locations
        // and so separate stage keys, so A's disposable is
        // not called.
        XCTAssertFalse(didFire)
    }

    func test_stageOne_disposes_onRepeatCallAtSameLocation() async throws {
        var didFire = false
        func call() async  {
            await AnyDisposable {
                didFire = true
            }
            // This line is executed twice and the source
            // code identity is used as the stage key.
            .stageOneByLocation()
        }
        await call()
        XCTAssertFalse(didFire)
        await call()
        XCTAssert(didFire)
    }

}
