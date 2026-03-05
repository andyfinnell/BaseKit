public struct Pattern: Codable, Hashable, Sendable {
    public let name: String
    public let shapes: [DecoratedShape]
    public let tileWidth: Double
    public let tileHeight: Double
    public let patternTransform: Transform?
    public let boundingBox: Rect?
    public let contentTransform: Transform?

    public init(
        name: String,
        shapes: [DecoratedShape],
        tileWidth: Double = 0,
        tileHeight: Double = 0,
        patternTransform: Transform? = nil,
        boundingBox: Rect? = nil,
        contentTransform: Transform? = nil
    ) {
        self.name = name
        self.shapes = shapes
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.patternTransform = patternTransform
        self.boundingBox = boundingBox
        self.contentTransform = contentTransform
    }
}
