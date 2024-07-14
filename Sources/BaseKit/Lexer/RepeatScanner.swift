public enum Repeat: Hashable, Sendable {
    case count(Int)
    case forever
}

public struct RepeatScanner<ElementScanner: Scannable>: Scannable {
    public typealias ScannerOutput = [ElementScanner.ScannerOutput]
    
    private let element: @Sendable () -> ElementScanner
    private let minimum: Int
    private let maximum: Repeat
    
    public init(
        minimum: Int = 0,
        maximum: Repeat = .forever,
        @ScannerBuilder element: @escaping @Sendable () -> ElementScanner
    ) {
        self.element = element
        self.minimum = minimum
        self.maximum = maximum
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        var output = [ElementScanner.ScannerOutput]()
        var currentIndex = input
        
        while currentIndex.notEnd,
              let elementMatch = try element().scan(startingAt: currentIndex) {
            
            // Since we got a match update
            output.append(elementMatch.value)
            currentIndex = elementMatch.remaining
            
            // Check to see if we've reached our maximum
            if case let .count(maximumCount) = maximum, output.count >= maximumCount {
                break // stop the loop
            }
        }
        
        // Make sure we've hit our minimum
        if output.count < minimum {
            return nil // no match
        }
        
        return ScannerResult(remaining: currentIndex, value: output)
    }

}
