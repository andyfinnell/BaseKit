import Foundation

public struct Pattern: Codable, Hashable, Sendable {
    public let name: String
    public let imageData: Data // TODO: how to make this efficient in rendering? cache?
    public let tileWidth: Double
    public let tileHeight: Double
    public let patternTransform: Transform?
    public let boundingBox: Rect?

    public init(
        name: String,
        imageData: Data,
        tileWidth: Double = 0,
        tileHeight: Double = 0,
        patternTransform: Transform? = nil,
        boundingBox: Rect? = nil
    ) {
        self.name = name
        self.imageData = imageData
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.patternTransform = patternTransform
        self.boundingBox = boundingBox
    }
}
