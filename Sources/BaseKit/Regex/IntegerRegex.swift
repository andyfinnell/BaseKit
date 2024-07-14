import RegexBuilder
import Foundation

public struct IntegerRegex {
    private let numberOfDigits: Int?
    private let radix: Int
    
    public init(numberOfDigits: Int? = nil, radix: Int = 10) {
        self.numberOfDigits = numberOfDigits
        self.radix = radix
    }
}

extension IntegerRegex: Scannable {
    public typealias ScannerOutput = Int
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<Int>? {
        scanInteger(input)
    }
}

extension IntegerRegex: CustomConsumingRegexComponent {
    public typealias RegexOutput = Int

    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Int)? {
        let source = Source(text: input, startingAt: index, endingBefore: bounds.upperBound, filename: "_")
        let cursor = Cursor(source: source, index: source.startIndex)
        guard let whole = scanInteger(cursor) else {
            return nil // no match
        }
        return (upperBound: whole.remaining.index.index, output: whole.value)
    }
}

private extension IntegerRegex {
    func scanInteger(_ cursor: Cursor<Source>) -> ScannerResult<Int>? {
        var current = cursor
        var accumulator = 0
        var places = 0
        while let value = current.toInt(radix: radix) {
            accumulator = (accumulator * radix) + value
            places += 1
            current = current.advance()
            
            if let numberOfDigits, places >= numberOfDigits {
                break
            }
        }
        if current == cursor {
            return nil
        }
        if let numberOfDigits, places != numberOfDigits {
            return nil
        }
        return ScannerResult(remaining: current, value: accumulator)
    }
}
