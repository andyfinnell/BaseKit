public struct TextRun: Hashable, Codable, Sendable {
    public enum Attribute: Hashable, Codable, Sendable {
        case fontName(String)
        case fontSize(Double)
        case textAlign(TextAlignment)
    }

    public let text: String
    public let attributes: [Attribute]
    
    public init(text: String, attributes: [Attribute]) {
        self.text = text
        self.attributes = attributes
    }
}
