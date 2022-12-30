import DisposableInterface

extension DisposableStage {

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

  fileprivate static let indefinite = DisposableStage()
  fileprivate static var identifiedStage = [String: Disposable]()

}

extension Disposable {
  public func stageIndefinitely(
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column
  ) {
    stage(
      fileID: fileID,
      line: line,
      column: column,
      on: DisposableStage.indefinite
    )
  }

  public func stageOne(by token: StaticString) {
    let token = "\(token)"
    DisposableStage.identifiedStage[token]?.dispose()
    DisposableStage.identifiedStage[token] = self
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
