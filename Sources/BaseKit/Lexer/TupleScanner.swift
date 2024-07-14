
private struct TupleNoMatchError: Error {
}

public struct TupleScanner<each S: Scannable>: Scannable {
    public typealias ScannerOutput =  (repeat (each S).ScannerOutput)
    
    let scanners: (repeat each S)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<(repeat (each S).ScannerOutput)>? {
        do {
            var cursor = input
            let value = try  (repeat (each scanners).scan(&cursor))
            return ScannerResult(remaining: cursor, value: value)
        } catch _ as TupleNoMatchError {
            return nil
        }
    }
}

private extension Scannable {
    func scan(_ cursor: inout Cursor<Source>) throws -> ScannerOutput {
        guard let result = try scan(startingAt: cursor) else {
            throw TupleNoMatchError()
        }
        cursor = result.remaining
        return result.value
    }
}
