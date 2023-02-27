import Disposable
import XCTest

// MARK: - TaskBridgeTests

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
    disposeStage.dispose()
    XCTAssert(task.isCancelled)
  }

  // This test shows the cancelsOnDeinit can work
  @MainActor
  func test_task_spinsAcrossFlush() async throws {
    var didFire = false
    let disposeStage = DisposableStage()
    Task { @MainActor in
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

  @MainActor
  func test_task_cancelsOnDeinit() async throws {
    var didFire = false
    ({
      let disposeStage = DisposableStage()
      Task { @MainActor in
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
    })()
    await Task.flush()
    XCTAssert(didFire)
  }
}

extension Task where Failure == Never, Success == Void {
  static func flush(count: Int = 25) async {
    for _ in 0..<count {
      _ = await Task<Void, Error> { try await Task<Never, Never>.sleep(nanoseconds: 1_000_000) }.result
    }
  }
}
