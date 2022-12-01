import DisposableInterface

extension DisposalStage {

    public static func resetIndefinite() {
        indefinite.reset()
    }

    public static func resetIdentified() {
        for d in identifiedStage.values {
            d.dispose()
        }
        identifiedStage = [:]
    }

    public static func dispose(identified: StaticString) {
        identifiedStage
            .removeValue(forKey: "\(identified)")?
            .dispose()
    }

    fileprivate static let indefinite = DisposalStage()
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
            on: DisposalStage.indefinite
        )
    }

    public func stageOne(by token: StaticString) {
        let token = "\(token)"
        DisposalStage.identifiedStage[token]?.dispose()
        DisposalStage.identifiedStage[token] = self
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
        DisposalStage.identifiedStage[location]?.dispose()
        DisposalStage.identifiedStage[location] = self
    }

}
