public struct Gradient: Hashable, Codable, Sendable {
    public enum Kind: String, Hashable, Codable, Sendable {
        case linear
        case radial
    }

    public enum SpreadMethod: String, Hashable, Codable, Sendable {
        case pad
        case reflect
        case `repeat`
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
    public let spreadMethod: SpreadMethod
    public let gradientTransform: Transform?
    public let focalPoint: Point?

    public init(
        kind: Kind,
        start: Point,
        end: Point,
        stops: [Stop],
        boundingBox: Rect?,
        spreadMethod: SpreadMethod = .pad,
        gradientTransform: Transform? = nil,
        focalPoint: Point? = nil
    ) {
        self.kind = kind
        self.start = start
        self.end = end
        self.stops = stops
        self.boundingBox = boundingBox
        self.spreadMethod = spreadMethod
        self.gradientTransform = gradientTransform
        self.focalPoint = focalPoint
    }
}
