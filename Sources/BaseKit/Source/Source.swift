import Foundation

public final class Source {
    private let text: String
    private let indices: [Index]
    public let filename: String
    public let startIndex: SourceIndex
    public let endIndex: SourceIndex
    
    public convenience init(text: String, filename: String) {
        self.init(text: text, startingAt: text.startIndex, endingBefore: text.endIndex, filename: filename)
    }

    public init(text: String, startingAt: String.Index, endingBefore: String.Index, filename: String) {
        self.text = text
        self.filename = filename
        
        var nextLine = 1
        var nextColumn = 1
        var foundStartIndex: Index?
        var foundEndIndex: Index?
        let indices = text.indices.enumerated().map { i, index in
            let newValue = Index(index: index, line: nextLine, column: nextColumn, indexIndex: i)
            if index == startingAt {
                foundStartIndex = newValue
            }
            if index == endingBefore {
                foundEndIndex = newValue
            }
            if index < text.endIndex && text[index].isNewline {
                nextLine = nextLine + 1
                nextColumn = 1
            } else {
                nextLine = nextLine
                nextColumn = nextColumn + 1
            }
            return newValue
        }
        self.indices = indices
        self.startIndex = foundStartIndex ?? Index(index: text.startIndex, line: 1, column: 1, indexIndex: 0)
        self.endIndex = foundEndIndex ?? Index(index: text.endIndex, line: nextLine, column: nextColumn, indexIndex: indices.count)
    }

    public struct Index {
        let index: String.Index
        let line: Int
        let column: Int
        let indexIndex: Int
    }
            
    public func substring(from startIndex: SourceIndex, upTo endIndex: SourceIndex) -> Substring {
        text[startIndex.index..<endIndex.index]
    }
    
    public func substring(from index: SourceIndex, ofLength length: Int) -> Substring {
        if let stopIndex = text.index(index.index, offsetBy: length, limitedBy: text.endIndex) {
            return text[index.index..<stopIndex]
        } else {
            return text[index.index..<text.endIndex]
        }
    }
    
    public func hasPrefix(_ prefix: String, from index: SourceIndex) -> Bool {
        text[index.index..<text.endIndex].hasPrefix(prefix)
    }
}

extension Source.Index: Comparable {
    public static func ==(lhs: Source.Index, rhs: Source.Index) -> Bool {
        lhs.index == rhs.index
            && lhs.line == rhs.line
            && lhs.column == rhs.column
    }
    
    public static func <(lhs: Source.Index, rhs: Source.Index) -> Bool {
        lhs.index < rhs.index
    }
}

extension Source.Index: CustomStringConvertible {
    public var description: String {
        "L\(line)C\(column)"
    }
}

extension Source: CursorSource {
    public typealias SourceIndex = Source.Index
    public typealias Element = Character
        
    public func index(after index: SourceIndex) -> SourceIndex {
        if (index.indexIndex + 1) < indices.count {
            return indices[index.indexIndex + 1]
        } else {
            return endIndex
        }
    }
    
    public func index(before index: SourceIndex) -> SourceIndex? {
        if index.indexIndex > 0 {
            return indices[index.indexIndex - 1]
        } else {
            return nil
        }
    }
    
    public subscript(_ index: SourceIndex) -> Character {
        text[index.index]
    }
}
