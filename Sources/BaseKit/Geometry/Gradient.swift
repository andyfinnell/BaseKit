public struct Gradient: Hashable, Codable, Sendable {
    public enum Kind: String, Hashable, Codable, Sendable {
        case linear
        case radial
    }
    
    public struct Stop: Hashable, Codable, Sendable {
        public let offset: Double
        public let color: Color
        
        public init(offset: Double, color: Color) {
            self.offset = offset
            self.color = color
        }
    }

    public let kind: Kind
    public let start: Point
    public let end: Point
    public let stops: [Stop]
    public let boundingBox: Rect?
    
    public init(kind: Kind, start: Point, end: Point, stops: [Stop], boundingBox: Rect?) {
        self.kind = kind
        self.start = start
        self.end = end
        self.stops = stops
        self.boundingBox = boundingBox
    }
}
