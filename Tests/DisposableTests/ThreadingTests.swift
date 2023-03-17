// import Disposable
// import XCTest
//
//// MARK: - ThreadingTests
//
// final class ThreadingTests: XCTestCase {
//
//  func test_anyDisposable_firesOnce() async throws {
//    var count = 0
//
//    let disposable = AnyDisposable {
//      count += 1
//    }
//
//    _ = await withTaskGroup(of: Void.self) { group in
//      for _ in 0..<10_000 {
//        group.addTask(priority: .background) {
//          disposable.dispose()
//        }
//      }
//    }
//
//    XCTAssertEqual(count, 1)
//  }
//
//  func test_disposableStage_firesEachDisposableOnce() async throws {
//    final class UnsafeCountRef: @unchecked Sendable {
//      var count = 0
//    }
//    var count = 0
//    let countRef = UnsafeCountRef()
//    let stage = DisposableStage()
//    let disposable = AnyDisposable {
//      count += 1
//    }
//
//    _ = await withTaskGroup(of: Void.self) { group in
//      for _ in 0..<10_000 {
//        group.addTask(priority: .background) {
//          AnyDisposable {
//            disposable.dispose()
//            countRef.count += 1
//          }.stage(on: stage)
//        }
//      }
//    }
//
//    _ = await withTaskGroup(of: Void.self) { group in
//      for _ in 0..<10_000 {
//        group.addTask(priority: .background) {
//          stage.dispose()
//        }
//      }
//    }
//
//    XCTAssertEqual(count, 1)
//    XCTAssertEqual(countRef.count, 10_000)
//  }
//
//  func test_stage_deinit_trigger() async throws {
//    var count = 0
//
//    var stageRef: DisposableStage? = DisposableStage()
//
//    try ({
//      let stage = try XCTUnwrap(stageRef)
//      for _ in 0..<10_000 {
//        AnyDisposable {
//          count += 1
//        }.stage(on: stage)
//
//        stageRef = stage
//      }
//      XCTAssertEqual(count, 0)
//    })()
//
//    XCTAssertEqual(count, 0)
//    stageRef = nil
//    XCTAssertEqual(count, 10_000)
//
//  }
//
//  func test_deinit_trigger() async throws {
//    var count = 0
//    ({
//      var hashables = Set<AnyHashable>()
//      for _ in 0..<10_000 {
//        let disp = AnyDisposable {
//          count += 1
//        }
//        _ = hashables.insert(disp)
//      }
//      XCTAssertEqual(count, 0)
//    })()
//
//    XCTAssertEqual(count, 10_000)
//  }
//
//  func test_deadlock() {
//    var count = 0
//    class Token {
//      func thing() {}
//    }
//    weak var weak1: Token?
//    weak var weak2: Token?
//    var disp2: AnyDisposable?
//    ({
//      let token1 = Token()
//      let token2 = Token()
//      weak1 = token1
//      weak2 = token2
//      let disp1 = AnyDisposable {
//        disp2?.dispose()
//        count += 1
//        token1.thing()
//      }
//      disp2 = AnyDisposable {
//        disp1.dispose()
//        count += 1
//        token2.thing()
//      }
//    })()
//
//    XCTAssertNotNil(weak2)
//    XCTAssertNotNil(weak1)
//    XCTAssertEqual(count, 0)
//
//    disp2?.dispose()
//
//    XCTAssertNil(weak2)
//    XCTAssertNil(weak1)
//    XCTAssertEqual(count, 2)
//  }
//
// }
