import Disposable
import XCTest

// MARK: - TaskBridgeTests

@MainActor
final class TaskBridgeTests: XCTestCase {

    // This test just shows the other tests can actually work
    func test_task_spinsWhenNotCancelled() async throws {
        var didFire = false
        let disposeStage = DisposalStage()
        Task {
            while true {
                await Task.yield()
                if Task.isCancelled {
                    didFire = true
                }
            }
        }
        .erase()
        .stage(on: disposeStage)
        XCTAssertFalse(didFire)
        XCTAssertNotNil(disposeStage)
        await attemptTaskFlushHack()
        XCTAssertFalse(didFire)
    }

    func test_task_cancelsOnDeinit() async throws {
        var didFire = false
        autoreleasepool {
            let disposeStage = DisposalStage()
            Task {
                while true {
                    await Task.yield()
                    if Task.isCancelled {
                        didFire = true
                    }
                }
            }
            .erase()
            .stage(on: disposeStage)
            XCTAssertFalse(didFire)
            XCTAssertNotNil(disposeStage)
        }
        await attemptTaskFlushHack()
        XCTAssert(didFire)
    }

    func test_task_cancelsOnDispose() async throws {
        var didFire = false
        let disposeStage = DisposalStage()
        Task {
            while true {
                await Task.yield()
                if Task.isCancelled {
                    didFire = true
                }
            }
        }
        .erase()
        .stage(on: disposeStage)
        XCTAssertFalse(didFire)
        XCTAssertNotNil(disposeStage)
        disposeStage.dispose()
        await attemptTaskFlushHack()
        XCTAssert(didFire)
    }
}

private func attemptTaskFlushHack(count: Int = 25) async {
    for _ in 0..<count {
        _ = await Task { try await Task.sleep(nanoseconds: 1 * USEC_PER_SEC) }.result
    }
}
