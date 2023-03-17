
import Foundation

extension DisposableStage {

  // MARK: Public

  public static func resetIndefinite() {
    indefinite.reset()
  }

  public static func resetIdentified() {
    let identified = identifiedStage
    identifiedStage = [:]
    for d in identified.values {
      d.dispose()
    }
  }

  public static func dispose(identified: StaticString) {
    identifiedStage
      .removeValue(forKey: "\(identified)")?
      .dispose()
  }

  // MARK: Fileprivate

  fileprivate static let indefinite = DisposableStage()
  fileprivate static let identifiedLock = NSLock()
  fileprivate static var identifiedStage = [String: Disposable]()

}

extension Disposable {
  public func stageIndefinitely(
  ) {
    stage(
      on: DisposableStage.indefinite
    )
  }

  public func stageOne(by token: StaticString) {
    let token = "\(token)"
    let old: (any Disposable)?
    DisposableStage.identifiedLock.lock()
    old = DisposableStage.identifiedStage[token]
    DisposableStage.identifiedStage[token] = self
    DisposableStage.identifiedLock.unlock()
    old?.dispose()
  }

  public func stageOneByLocation(
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column
  ) {
    stageOne(by: (fileID: fileID, line: line, column: column))
  }

  public func stageOne(by location: (fileID: String, line: Int, column: Int)) {
    let location = "\(location.fileID):\(location.line):\(location.column)"
    DisposableStage.identifiedStage[location]?.dispose()
    DisposableStage.identifiedStage[location] = self
  }

}
