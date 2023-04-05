import XCTest
@testable import Disposable

// MARK: - TaskBridgeTests

final class TaskBridgeTests: XCTestCase {

  func test_task_cancelsOnDispose() async throws {
    let disposeStage = DisposableStage()
    let task = Task {
      while true {
        await Task.yield()
      }
    }
    Disposables.make { task }
      .stage(on: disposeStage)

    XCTAssertFalse(task.isCancelled)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    XCTAssert(task.isCancelled)
  }

  @MainActor
  func test_builder_task_closure_executesAndCancelsOnDispose() async throws {
    let disposeStage = DisposableStage()
    var didExecute = false
    let isCancelled = Locked<Bool>(false)
    Disposables.make {
      Task { @MainActor in
        await withTaskCancellationHandler {
          didExecute = true
          while true {
            await Task.yield()
          }
        } onCancel: {
          isCancelled.value = true
        }
      }
    }
    .stage(on: disposeStage)

    await Flush.tasks(count: 100)
    XCTAssert(didExecute)
    XCTAssertFalse(isCancelled.value)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    await Flush.tasks(count: 100)
    XCTAssert(isCancelled.value)
  }

  @MainActor
  func test_init_task_closure_executesAndCancelsOnDispose() async throws {
    let disposeStage = DisposableStage()
    var didExecute = false
    let isCancelled = Locked<Bool>(false)
    Disposables.make {
      Task { @MainActor in
        await withTaskCancellationHandler {
          didExecute = true
          while true {
            await Task.yield()
          }
        } onCancel: {
          isCancelled.value = true
        }
      }
    }
    .stage(on: disposeStage)

    await Flush.tasks(count: 100)
    XCTAssert(didExecute)
    XCTAssertFalse(isCancelled.value)
    XCTAssertNotNil(disposeStage)
    disposeStage.dispose()
    await Flush.tasks(count: 100)
    XCTAssert(isCancelled.value)
  }

  /// This test shows the cancelsOnDeinit can work
  @MainActor
  func test_task_spinsAcrossFlush() async throws {
    var didFire = false
    let disposeStage = DisposableStage()
    let task = Task { @MainActor in
      while true {
        await Task.yield()
        if Task.isCancelled {
          didFire = true
        }
      }
    }
    Disposables.make { task }
      .stage(on: disposeStage)
    XCTAssertFalse(didFire)
    XCTAssertNotNil(disposeStage)
    await Flush.tasks()
    XCTAssertFalse(didFire)
  }

  @MainActor
  func test_task_cancelsOnDeinit() async throws {
    var didFire = false
    let run = {
      let disposeStage = DisposableStage()
      let task = Task { @MainActor in
        while true {
          await Task.yield()
          if Task.isCancelled {
            didFire = true
          }
        }
      }
      Disposables
        .make { task }
        .stage(on: disposeStage)
      XCTAssertFalse(didFire)
      XCTAssertNotNil(disposeStage)
    }
    run()
    await Flush.tasks()
    XCTAssert(didFire)
  }
}

// MARK: - Flush

enum Flush {
  static func tasks(count: Int = 25) async {
    for _ in 0 ..< count {
      _ = await Task<Void, Error> { try await Task<Never, Never>.sleep(nanoseconds: 1_000_000) }
        .result
    }
  }
}
