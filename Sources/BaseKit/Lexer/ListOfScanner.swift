import Foundation

public struct ListOfScanner<ElementScanner: Scannable, SeparatorScanner: Scannable>: Scannable {
    public typealias ScannerOutput = [ElementScanner.ScannerOutput]
    
    private let separator: @Sendable () -> SeparatorScanner
    private let element: @Sendable () -> ElementScanner
    
    public init(
        @ScannerBuilder separator: @escaping @Sendable () -> SeparatorScanner,
        @ScannerBuilder element: @escaping @Sendable () -> ElementScanner
    ) {
        self.separator = separator
        self.element = element
    }
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        guard let firstMatch = try element().scan(startingAt: input) else {
            return nil // no match
        }
        var output = [firstMatch.value]
        var currentIndex = firstMatch.remaining
        
        while currentIndex.notEnd,
              let separatorMatch = try separator().scan(startingAt: currentIndex) {
            // Skip over separator
            let nextElementIndex = separatorMatch.remaining
            guard nextElementIndex.notEnd else {
                break
            }
            
            guard let elementMatch = try element().scan(startingAt: nextElementIndex) else {
                break // no match
            }

            // Since we got a match update
            output.append(elementMatch.value)
            currentIndex = elementMatch.remaining
        }
        
        return ScannerResult(remaining: currentIndex, value: output)
    }
}
