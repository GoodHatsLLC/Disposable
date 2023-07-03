import Foundation

// MARK: - Disposables.stages

extension Disposables {
  public enum stages { }
}

extension Disposables.stages {

  // MARK: Public

  /// Reset all global convenience stages.
  ///
  /// The global stages are:
  /// - ``Disposable/stageIndefinitely()``
  /// - ``Disposable/stageByIdentity(token:)``
  /// - ``Disposable/stageByUniqueCallSite(fileID:line:column:)``
  public static func resetGlobalStages() { }

  /// Reset the ``Disposable/stageIndefinitely()`` stage,
  /// disposing any staged disposables and allowing reuse.
  public static func resetIndefiniteStage() {
    indefinite.reset()
  }

  /// Reset the ``Disposable/stageByIdentity(token:)`` stage,
  /// disposing any staged disposables and allowing reuse.
  public static func resetIdentityStage() {
    let identified = identifiedStage.withLock {
      let identified = $0.values
      $0.removeAll()
      return identified
    }
    for d in identified {
      d.dispose()
    }
  }

  /// Reset the ``Disposable/stageByUniqueCallSite(fileID:line:column:)`` stage,
  /// disposing any staged disposables and allowing reuse.
  public static func resetCallSiteStage() {
    let identified = callSiteStage.withLock {
      let identified = $0.values
      $0.removeAll()
      return identified
    }
    for d in identified {
      d.dispose()
    }
  }

  /// Dispose any disposable staged with ``Disposable/stageByIdentity(token:)``
  /// with the passed `token` value.
  public static func disposeByIdentity(token: StaticString) {
    identifiedStage.withLock { stage in
      stage
        .removeValue(forKey: "\(token)")
    }?.dispose()
  }

  // MARK: Fileprivate

  fileprivate static let indefinite = DisposableStage()
  fileprivate static var identifiedStage = Locked([String: any Disposable]())
  fileprivate static var callSiteStage = Locked([String: any Disposable]())

}

extension Disposable {
  /// Stage the Disposable until the end of program execution
  /// (or until ``Disposables/stages/resetIndefiniteStage()`` is called).
  public func stageIndefinitely() {
    stage(
      on: Disposables.stages.indefinite
    )
  }

  /// Stage the Disposable until the passed identity token is reused,
  /// ``Disposables/stages/disposeByIdentity(token:)`` is called,
  /// or ``Disposables/stages/resetIdentityStage()`` is called.
  public func stageByIdentity(token: StaticString) {
    let token = "\(token)"
    let old = Disposables.stages.identifiedStage.withLock { value in
      let old = value[token]
      value[token] = self
      return old
    }
    old?.dispose()
  }

  /// Stage the Disposable until the exact staging call-site is reused
  /// (or until ``Disposables/stages/resetCallSiteStage()`` is called).
  public func stageByUniqueCallSite(
    fileID: String = #fileID,
    line: Int = #line,
    column: Int = #column
  ) {
    stageByUniqueCallSite(location: (fileID: fileID, line: line, column: column))
  }

  @_spi(Implementation)
  public func stageByUniqueCallSite(location: (
    fileID: String,
    line: Int,
    column: Int
  )) {
    let location = "\(location.fileID):\(location.line):\(location.column)"
    let old = Disposables.stages.callSiteStage.withLock { stage in
      let old = stage[location]
      stage[location] = self
      return old
    }
    old?.dispose()
  }

}
