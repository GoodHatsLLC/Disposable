public struct DisposedStageError: Error {
    public init(file: String, line: Int, column: Int) {
        self.file = file
        self.line = line
        self.column = column
    }

    let file: String
    let line: Int
    let column: Int

    var description: String {
        """
        A Disposable was staged on a DisposalStage that had already
        been disposed. It was immediately disposed.
        \(file):\(line):\(column)
        """
    }
}
