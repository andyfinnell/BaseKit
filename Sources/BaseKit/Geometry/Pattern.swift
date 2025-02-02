import Foundation

public struct Pattern: Codable, Hashable, Sendable {
    public let name: String
    public let imageData: Data // TODO: how to make this efficient in rendering? cache?
    
    public init(name: String, imageData: Data) {
        self.name = name
        self.imageData = imageData
    }
}
