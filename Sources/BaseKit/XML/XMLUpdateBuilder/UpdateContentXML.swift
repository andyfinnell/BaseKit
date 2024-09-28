public struct UpdateContentXML: XMLUpdate {
    private let content: String
    
    public init(
        _ content: String
    ) {
        self.content = content
    }
    
    public func changes(for parentID: XMLID?) -> [XMLChange] {
        guard let parentID else {
            return [] // TODO: throw an error?
        }
        return [
            .update(XMLUpdateContentChange(valueID: parentID, content: content))
        ]
    }
    
    public var body: Never { fatalError() }
}
