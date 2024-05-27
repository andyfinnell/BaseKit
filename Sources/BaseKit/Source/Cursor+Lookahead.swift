import Foundation

public extension Cursor where S == Source {
    func prefix(_ length: Int) -> Substring {
        source.substring(from: self.index, ofLength: length)
    }
    
    func hasPrefix(_ string: String) -> Bool {
        source[self.index] == string[string.startIndex] && source.hasPrefix(string, from: self.index)
    }
}
