public struct TextRun: Hashable, Codable, Sendable {
    public enum Attribute: Hashable, Codable, Sendable {
        case fontName(String)
        case fontSize(Double)
        case textAlign(TextAlignment)
        case letterSpacing(Double)
        case wordSpacing(Double)
    }

    public let text: String
    public let attributes: [Attribute]
    public let decorations: [Decoration]?
    public let textDecorationLines: TextDecorationLine?
    public let dx: Double
    public let dy: Double

    public init(
        text: String,
        attributes: [Attribute],
        decorations: [Decoration]? = nil,
        textDecorationLines: TextDecorationLine? = nil,
        dx: Double = 0,
        dy: Double = 0
    ) {
        self.text = text
        self.attributes = attributes
        self.decorations = decorations
        self.textDecorationLines = textDecorationLines
        self.dx = dx
        self.dy = dy
    }
}

extension TextRun {
    public var needsPerRunRendering: Bool {
        decorations != nil || textDecorationLines != nil || dx != 0 || dy != 0
    }
}
