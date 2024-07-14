
public struct Alternate2Scanner<ScannerOutput, S0: Scannable, S1: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate3Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate4Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate5Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput,
          S4.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3, S4)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else if let result = try scanners.4.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate6Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput,
          S4.ScannerOutput == ScannerOutput, S5.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3, S4, S5)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else if let result = try scanners.4.scan(startingAt: input) {
            return result
        } else if let result = try scanners.5.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate7Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput,
          S4.ScannerOutput == ScannerOutput, S5.ScannerOutput == ScannerOutput,
          S6.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3, S4, S5, S6)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else if let result = try scanners.4.scan(startingAt: input) {
            return result
        } else if let result = try scanners.5.scan(startingAt: input) {
            return result
        } else if let result = try scanners.6.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate8Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable, S7: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput,
          S4.ScannerOutput == ScannerOutput, S5.ScannerOutput == ScannerOutput,
          S6.ScannerOutput == ScannerOutput, S7.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3, S4, S5, S6, S7)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else if let result = try scanners.4.scan(startingAt: input) {
            return result
        } else if let result = try scanners.5.scan(startingAt: input) {
            return result
        } else if let result = try scanners.6.scan(startingAt: input) {
            return result
        } else if let result = try scanners.7.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate9Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable, S7: Scannable, S8: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput,
          S4.ScannerOutput == ScannerOutput, S5.ScannerOutput == ScannerOutput,
          S6.ScannerOutput == ScannerOutput, S7.ScannerOutput == ScannerOutput,
          S8.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3, S4, S5, S6, S7, S8)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else if let result = try scanners.4.scan(startingAt: input) {
            return result
        } else if let result = try scanners.5.scan(startingAt: input) {
            return result
        } else if let result = try scanners.6.scan(startingAt: input) {
            return result
        } else if let result = try scanners.7.scan(startingAt: input) {
            return result
        } else if let result = try scanners.8.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}

public struct Alternate10Scanner<ScannerOutput, S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable, S7: Scannable, S8: Scannable, S9: Scannable>: Scannable
    where S0.ScannerOutput == ScannerOutput, S1.ScannerOutput == ScannerOutput,
          S2.ScannerOutput == ScannerOutput, S3.ScannerOutput == ScannerOutput,
          S4.ScannerOutput == ScannerOutput, S5.ScannerOutput == ScannerOutput,
          S6.ScannerOutput == ScannerOutput, S7.ScannerOutput == ScannerOutput,
          S8.ScannerOutput == ScannerOutput, S9.ScannerOutput == ScannerOutput {
    
    let scanners: (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9)
    
    public func scan(startingAt input: Cursor<Source>) throws -> ScannerResult<ScannerOutput>? {
        if let result = try scanners.0.scan(startingAt: input) {
            return result
        } else if let result = try scanners.1.scan(startingAt: input) {
            return result
        } else if let result = try scanners.2.scan(startingAt: input) {
            return result
        } else if let result = try scanners.3.scan(startingAt: input) {
            return result
        } else if let result = try scanners.4.scan(startingAt: input) {
            return result
        } else if let result = try scanners.5.scan(startingAt: input) {
            return result
        } else if let result = try scanners.6.scan(startingAt: input) {
            return result
        } else if let result = try scanners.7.scan(startingAt: input) {
            return result
        } else if let result = try scanners.8.scan(startingAt: input) {
            return result
        } else if let result = try scanners.9.scan(startingAt: input) {
            return result
        } else {
            return nil
        }
    }
}
