
public struct ArrayXMLUpdate<Element: XMLUpdate>: XMLUpdate {
    private let elements: [Element]
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
        
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        elements.flatMap { $0.changes(for: parentID) }
    }
    
    public var body: Never { fatalError() }
}
