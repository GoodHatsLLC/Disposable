import Disposable
import XCTest

// MARK: - TaskBridgeTests

@MainActor
final class TaskBridgeTests: XCTestCase {

    func test_task_cancelsOnDispose() async throws {
        let disposeStage = DisposableStage()
        let task = Task {
            while true {
                await Task.yield()
            }
        }
        task
            .erase()
            .stage(on: disposeStage)
        XCTAssertFalse(task.isCancelled)
        XCTAssertNotNil(disposeStage)
        await disposeStage.dispose()
        XCTAssert(task.isCancelled)
    }

    // This test shows the cancelsOnDeinit can work
    func test_task_spinsAcrossFlush() async throws {
        var didFire = false
        let disposeStage = DisposableStage()
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
        await Task.flush()
        XCTAssertFalse(didFire)
    }

    func test_task_cancelsOnDeinit() async throws {
        var didFire = false
        autoreleasepool {
            let disposeStage = DisposableStage()
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
        await Task.flush()
        XCTAssert(didFire)
    }
}

extension Task where Failure == Never, Success == Void {
    static func flush(count: Int = 25) async {
        for _ in 0..<count {
            _ = await Task<Void, Error> { try await Task<Never, Never>.sleep(nanoseconds: 1 * USEC_PER_SEC) }.result
        }
    }
}
