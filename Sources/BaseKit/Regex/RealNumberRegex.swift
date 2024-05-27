import RegexBuilder
import Foundation

public struct RealNumberRegex: CustomConsumingRegexComponent {
    public typealias RegexOutput = Double
    
    public init() {}
    
    public func consuming(
        _ input: String,
        startingAt index: String.Index,
        in bounds: Range<String.Index>
    ) throws -> (upperBound: String.Index, output: Double)? {
        let source = Source(text: input, startingAt: index, filename: "_")
        let cursor = Cursor(source: source, index: source.startIndex)
        let hasMinus = scanSign(cursor)
        guard var whole = scanInteger(hasMinus.remaining, radix: 10) else {
            return nil // no match
        }
        if hasMinus.value {
            whole = whole.map { $0.negate() }
        }

        // Check for fractional part
        var fraction: ScannerResult<Integer>?
        if whole.remaining == "." {
            fraction = scanInteger(whole.remaining.advance(), radix: 10)
        }
        
        // Check for exponent
        var exponent: ScannerResult<Integer>?
        let preExponent = fraction.map { $0.remaining } ?? whole.remaining
        if preExponent == "e" || preExponent == "E" {
            let hasExponentMinus = scanSign(preExponent.advance())
            if let unsignedExponent = scanInteger(hasExponentMinus.remaining, radix: 10) {
                if hasExponentMinus.value {
                    exponent = unsignedExponent.map { $0.negate() }
                } else {
                    exponent = unsignedExponent
                }
            }
        }
        
        let stop = exponent.map { $0.remaining } ?? (fraction.map { $0.remaining } ?? whole.remaining)
        let value: Double
        if fraction != nil || exponent != nil {
            var floatValue = Double(whole.value.value)
            if let fraction = fraction {
                let fractionExponent = pow(10.0, -Double(fraction.value.places))
                floatValue += Double(fraction.value.value) * fractionExponent
            }
            if let exponent = exponent {
                let exponentValue = pow(10.0, Double(exponent.value.value))
                floatValue *= exponentValue
            }
            value = floatValue
        } else {
            value = Double(whole.value.value)
        }
        return (upperBound: stop.index.index, output: value)
    }
}

private extension RealNumberRegex {
    func scanSign(_ cursor: Cursor<Source>) -> ScannerResult<Bool> {
        var current = cursor
        let isMinus = current == "-"
        if isMinus || current == "+" {
            current = current.advance()
        }
        return ScannerResult(remaining: current, value: isMinus)
    }
        
    struct Integer {
        let value: Int
        let places: Int
        
        func negate() -> Integer {
            .init(value: -value,
                  places: places)
        }
    }
    
    func scanInteger(_ cursor: Cursor<Source>, radix: Int) -> ScannerResult<Integer>? {
        var current = cursor
        var accumulator = 0
        var places = 0
        while let value = current.toInt(radix: radix) {
            accumulator = (accumulator * radix) + value
            places += 1
            current = current.advance()
        }
        if current == cursor {
            return nil
        }
        return ScannerResult(remaining: current, value: Integer(value: accumulator, places: places))
    }

}

private extension Cursor where S.Element == Character {
    var isDecimalDigit: Bool {
        guard let ch = element else {
            return false
        }
        return ch.isDecimalDigit
    }
}

private extension Character {
    var isDecimalDigit: Bool {
        return Character.allDecimalDigit.contains(self)
    }
    
    static let allDecimalDigit = Set(arrayLiteral: Character("0"),
                                     Character("1"), Character("2"), Character("3"), Character("4"),
                                     Character("5"), Character("6"), Character("7"), Character("8"),
                                     Character("9"))
}
