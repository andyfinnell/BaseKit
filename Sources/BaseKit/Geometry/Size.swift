import Foundation

public struct Size: Hashable, Codable, Sendable {
    public var width: Real
    public var height: Real
    
    public init(width: Real, height: Real) {
        self.width = width
        self.height = height
    }
    
    public static let zero = Size(width: 0, height: 0)
    
    public func distance(to size: Size) -> Real {
        let widthDelta = size.width - width
        let heightDelta = size.height - height
        return sqrt(widthDelta * widthDelta + heightDelta * heightDelta)
    }
}
