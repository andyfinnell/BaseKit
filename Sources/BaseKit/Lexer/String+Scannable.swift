
extension String: Scannable {
    public typealias ScannerOutput = String
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<String>? {
        var currentIndex = startIndex
        var currentCursor = input
        
        while currentIndex < endIndex && currentCursor.notEnd {
            guard currentCursor == self[currentIndex] else {
                return nil
            }
            
            currentIndex = index(after: currentIndex)
            currentCursor = currentCursor.advance()
        }
        
        guard currentIndex == endIndex else {
            // Confirm we ran out of string to match. Otherwise, we didn't match
            return nil
        }
        
        return ScannerResult(remaining: currentCursor, value: self)
    }
}

public extension String {
    func wholeMatch<S: Scannable>(ofScanner scanner: S) throws -> S.ScannerOutput? {
        let source = Source(text: self, startingAt: startIndex, endingBefore: endIndex, filename: "_")
        let cursor = Cursor(source: source, index: source.startIndex)
        guard let result = try scanner.scan(startingAt: cursor) else {
            return nil
        }
        guard result.remaining.isEnd else {
            return nil // didn't match all of it
        }
        return result.value
    }
    
    func prefixMatch<S: Scannable>(ofScanner scanner: S) throws -> S.ScannerOutput? {
        let source = Source(text: self, startingAt: startIndex, endingBefore: endIndex, filename: "_")
        let cursor = Cursor(source: source, index: source.startIndex)
        guard let result = try scanner.scan(startingAt: cursor) else {
            return nil
        }
        return result.value
    }

}
