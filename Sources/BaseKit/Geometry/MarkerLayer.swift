public struct MarkerPlacement: Hashable, Codable, Sendable {
    public let position: Point
    public let angle: Double
    public let shapes: [DecoratedShape]
    public let markerTransform: Transform

    public init(
        position: Point,
        angle: Double,
        shapes: [DecoratedShape],
        markerTransform: Transform
    ) {
        self.position = position
        self.angle = angle
        self.shapes = shapes
        self.markerTransform = markerTransform
    }
}

public struct MarkerLayer: Hashable, Codable, Sendable {
    public let placements: [MarkerPlacement]

    public init(placements: [MarkerPlacement]) {
        self.placements = placements
    }
}
