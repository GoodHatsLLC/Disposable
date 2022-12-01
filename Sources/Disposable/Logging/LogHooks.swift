public enum LogHooks {
    /// An overridable logging closure allowing external consumers to receive
    /// notifications for usage errors.
    public static var log: (Error) -> Void = { error in
        print(error)
    }
}
