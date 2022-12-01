import DisposableInterface

extension DisposableStage {

  public static func resetIndefinite() async {
    await indefinite.reset()
  }

  public static func resetIdentified() async {
    let identified = identifiedStage
    identifiedStage = [:]
    await withThrowingTaskGroup(of: Void.self) { group in
      for d in identified.values {
        group.addTask {
          await d.dispose()
        }
      }
    }
  }

  public static func dispose(identified: StaticString) async {
    await identifiedStage
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

  public func stageOne(by token: StaticString) async {
    let token = "\(token)"
    await DisposableStage.identifiedStage[token]?.dispose()
    DisposableStage.identifiedStage[token] = self
  }

  public func stageOneByLocation(
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column
  ) async {
    await stageOne(by: (fileID: fileID, line: line, column: column))
  }

  public func stageOne(by location: (fileID: String, line: Int, column: Int)) async {
    let location = "\(location.fileID):\(location.line):\(location.column)"
    await DisposableStage.identifiedStage[location]?.dispose()
    DisposableStage.identifiedStage[location] = self
  }

}
