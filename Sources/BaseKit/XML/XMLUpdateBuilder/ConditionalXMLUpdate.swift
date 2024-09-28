
public struct ConditionalXMLUpdate<True: XMLUpdate, False: XMLUpdate>: XMLUpdate {
    public enum Value {
        case `true`(True)
        case `false`(False)
    }
    private let value: Value
    
    public init(_ value: Value) {
        self.value = value
    }
        
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        switch value {
        case let .true(value):
            value.changes(for: parentID)
        case let .false(value):
            value.changes(for: parentID)
        }
    }
    
    public var body: Never { fatalError() }
}
