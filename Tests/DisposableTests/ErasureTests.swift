import Disposable
import XCTest

// MARK: - ErasureTests

@MainActor
final class ErasureTests: XCTestCase {

    func test_erasedDisposable_firesOnDeinit() throws {
        var didFire = false
        autoreleasepool {
            let disposable = AnyDisposable {
                didFire = true
            }.erase()
            XCTAssertFalse(didFire)
            XCTAssertNotNil(disposable)
        }
        XCTAssert(didFire)
    }

    func test_disposable_firesOnDispose() throws {
        var didFire = false
        let disposable = AnyDisposable {
            didFire = true
        }.erase()
        XCTAssertFalse(didFire)
        XCTAssertNotNil(disposable)
        disposable.dispose()
        XCTAssert(didFire)
    }

    func test_anyDisposable_erasesToSelf() throws {
        // Erase should not change a pre-erased value.
        let anyDisposable = AnyDisposable {}.erase()
        let anyDisposable2 = anyDisposable.erase()
        XCTAssert(anyDisposable === anyDisposable2)

        // eraseToDisposable() should pass through to erase.
        let anyDisposable3 = anyDisposable2.eraseToDisposable()
        let anyDisposable4 = anyDisposable3.eraseToDisposable()
        XCTAssert(anyDisposable3 === anyDisposable4)
    }
}
