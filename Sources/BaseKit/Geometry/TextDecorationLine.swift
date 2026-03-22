public struct TextDecorationLine: OptionSet, Hashable, Sendable, Codable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let underline = TextDecorationLine(rawValue: 1 << 0)
    public static let overline = TextDecorationLine(rawValue: 1 << 1)
    public static let lineThrough = TextDecorationLine(rawValue: 1 << 2)
}
