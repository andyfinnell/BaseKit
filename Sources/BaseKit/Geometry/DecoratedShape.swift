public struct DecoratedShape: Hashable, Codable, Sendable {
    public let path: BezierPath
    public let transform: Transform
    public let decorations: [Decoration]
    public let opacity: Double

    public init(
        path: BezierPath,
        transform: Transform = .identity,
        decorations: [Decoration] = [],
        opacity: Double = 1.0
    ) {
        self.path = path
        self.transform = transform
        self.decorations = decorations
        self.opacity = opacity
    }
}
