import Disposable
import XCTest

// MARK: - DisposableTests

@MainActor
final class DisposableTests: XCTestCase {

    func test_disposable_firesOnDeinit() throws {
        var didFire = false
        autoreleasepool {
            let disposable = AnyDisposable {
                didFire = true
            }
            XCTAssertFalse(didFire)
            XCTAssertNotNil(disposable)
        }
        XCTAssert(didFire)
    }

    func test_disposable_firesOnDispose() throws {
        var didFire = false
        let disposable = AnyDisposable {
            didFire = true
        }
        XCTAssertFalse(didFire)
        XCTAssertNotNil(disposable)
        disposable.dispose()
        XCTAssert(didFire)
    }
}
