public protocol XMLFormattable {
    func xmlFormatted() -> String
}

extension Double: XMLFormattable {
    public func xmlFormatted() -> String {
        formatted(.number.grouping(.never))
    }
}
