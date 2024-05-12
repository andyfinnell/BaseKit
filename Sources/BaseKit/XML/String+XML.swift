
public extension String {
    private static let entityMap: [Character: String] = [
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&apos;",
    ]
    
    func encodeXMLEntities() -> String {
        String(flatMap { ch in
            if let replacement = String.entityMap[ch] {
                return replacement
            } else {
                return String(ch)
            }
        })
    }
}
