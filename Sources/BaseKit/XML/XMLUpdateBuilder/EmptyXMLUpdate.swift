
public struct EmptyXMLUpdate: XMLUpdate {
    public init() {}
    
    public func changes(for parentID: XMLID?) -> [XMLChange] { [] }
    public var body: Never { fatalError() }
}
