import Foundation

public struct LogTag: RawRepresentable, Hashable {
    public let rawValue: String
    
    public static let http = LogTag("http")
    public static let general = LogTag("general")
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}
