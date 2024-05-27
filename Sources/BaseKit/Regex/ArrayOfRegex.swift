import RegexBuilder
import Foundation

public struct ArrayOfRegex<T, S>: CustomConsumingRegexComponent {
    public typealias RegexOutput = [T]
    
    private let separator: Regex<S>
    private let element: Regex<T>
    
    public init(separator: any RegexComponent<S>, element: any RegexComponent<T>) {
        self.separator = separator.regex
        self.element = element.regex
    }
    
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: [T])? {
        guard let firstMatch = try element.prefixMatch(in: input[index..<input.endIndex]) else {
            return nil // no match
        }
        var output = [firstMatch.output]
        var currentIndex = firstMatch.range.upperBound
        
        while currentIndex < input.endIndex,
              let separatorMatch = try separator.prefixMatch(in: input[currentIndex..<input.endIndex]) {
            // Skip over separator
            let nextElementIndex = separatorMatch.range.upperBound
            guard nextElementIndex < input.endIndex else {
                break
            }
            
            guard let elementMatch = try element.prefixMatch(in: input[nextElementIndex..<input.endIndex]) else {
                break // no match
            }

            // Since we got a match update
            output.append(elementMatch.output)
            currentIndex = elementMatch.range.upperBound
        }
        
        return (upperBound: currentIndex, output: output)
    }
}
