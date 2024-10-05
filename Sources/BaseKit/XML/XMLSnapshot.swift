import Foundation

public struct XMLSnapshot: Sendable {
    public let roots: [XMLID]
    public let values: [XMLID: XMLValue]
    
    public init(roots: [XMLID], values: [XMLID: XMLValue]) {
        self.roots = roots
        self.values = values
    }
}
