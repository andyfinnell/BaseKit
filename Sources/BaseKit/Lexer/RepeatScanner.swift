public enum Repeat: Hashable, Sendable {
    case count(Int)
    case forever
}

public struct RepeatScanner<ScannerOutput, ElementScanner: Scannable>: Scannable {
    private let element: @Sendable () -> ElementScanner
    private let initialValue: @Sendable () -> ScannerOutput
    private let reduce: @Sendable (inout ScannerOutput, ElementScanner.ScannerOutput) -> Void
    private let minimum: Int
    private let maximum: Repeat
    
    public init(
        minimum: Int,
        maximum: Repeat,
        initialValue: @escaping @Sendable () -> ScannerOutput,
        reduce: @escaping @Sendable (inout ScannerOutput, ElementScanner.ScannerOutput) -> Void,
        @ScannerBuilder element: @escaping @Sendable () -> ElementScanner
    ) {
        self.element = element
        self.initialValue = initialValue
        self.reduce = reduce
        self.minimum = minimum
        self.maximum = maximum
    }

    public init(
        minimum: Int = 0,
        maximum: Repeat = .forever,
        as type: ScannerOutput.Type,
        @ScannerBuilder element: @escaping @Sendable () -> ElementScanner
    ) where ScannerOutput == Array<ElementScanner.ScannerOutput> {
        self.element = element
        self.initialValue = { Array<ElementScanner.ScannerOutput>() }
        self.reduce = { $0.append($1) }
        self.minimum = minimum
        self.maximum = maximum
    }

    public init(
        minimum: Int = 0,
        maximum: Repeat = .forever,
        as type: ScannerOutput.Type,
        @ScannerBuilder element: @escaping @Sendable () -> ElementScanner
    ) where ScannerOutput == String, ElementScanner.ScannerOutput == String {
        self.element = element
        self.initialValue = { "" }
        self.reduce = { $0.append($1) }
        self.minimum = minimum
        self.maximum = maximum
    }

    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        var output = initialValue()
        var currentIndex = input
        var count = 0
        
        while currentIndex.notEnd,
              let elementMatch = try element().scan(startingAt: currentIndex) {
            
            // Since we got a match update
            reduce(&output, elementMatch.value)
            currentIndex = elementMatch.remaining
            count += 1
            
            // Check to see if we've reached our maximum
            if case let .count(maximumCount) = maximum, count >= maximumCount {
                break // stop the loop
            }
        }
        
        // Make sure we've hit our minimum
        if count < minimum {
            return nil // no match
        }
        
        return ScannerResult(remaining: currentIndex, value: output)
    }

}
