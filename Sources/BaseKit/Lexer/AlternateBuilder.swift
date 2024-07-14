@resultBuilder
public struct AlternateBuilder {
    public static func buildBlock() -> EmptyScanner {
        EmptyScanner()
    }
    
    public static func buildBlock<S: Scannable>(_ scanner: S) -> S {
        scanner
    }
    
    public static func buildBlock<S0: Scannable, S1: Scannable>(
        _ s0: S0, _ s1: S1
    ) -> Alternate2Scanner<S0.ScannerOutput, S0, S1>
    where S0.ScannerOutput == S1.ScannerOutput {
        Alternate2Scanner(scanners: (s0, s1))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2
    ) -> Alternate3Scanner<S0.ScannerOutput, S0, S1, S2>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput {
        Alternate3Scanner(scanners: (s0, s1, s2))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3
    ) -> Alternate4Scanner<S0.ScannerOutput, S0, S1, S2, S3>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput {
        Alternate4Scanner(scanners: (s0, s1, s2, s3))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4
    ) -> Alternate5Scanner<S0.ScannerOutput, S0, S1, S2, S3, S4>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput, S0.ScannerOutput == S4.ScannerOutput {
        Alternate5Scanner(scanners: (s0, s1, s2, s3, s4))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5
    ) -> Alternate6Scanner<S0.ScannerOutput, S0, S1, S2, S3, S4, S5>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput, S0.ScannerOutput == S4.ScannerOutput,
          S0.ScannerOutput == S5.ScannerOutput {
        Alternate6Scanner(scanners: (s0, s1, s2, s3, s4, s5))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6
    ) -> Alternate7Scanner<S0.ScannerOutput, S0, S1, S2, S3, S4, S5, S6>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput, S0.ScannerOutput == S4.ScannerOutput,
          S0.ScannerOutput == S5.ScannerOutput, S0.ScannerOutput == S6.ScannerOutput {
        Alternate7Scanner(scanners: (s0, s1, s2, s3, s4, s5, s6))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable, S7: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7
    ) -> Alternate8Scanner<S0.ScannerOutput, S0, S1, S2, S3, S4, S5, S6, S7>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput, S0.ScannerOutput == S4.ScannerOutput,
          S0.ScannerOutput == S5.ScannerOutput, S0.ScannerOutput == S6.ScannerOutput,
          S0.ScannerOutput == S7.ScannerOutput {
        Alternate8Scanner(scanners: (s0, s1, s2, s3, s4, s5, s6, s7))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable, S7: Scannable, S8: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8
    ) -> Alternate9Scanner<S0.ScannerOutput, S0, S1, S2, S3, S4, S5, S6, S7, S8>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput, S0.ScannerOutput == S4.ScannerOutput,
          S0.ScannerOutput == S5.ScannerOutput, S0.ScannerOutput == S6.ScannerOutput,
          S0.ScannerOutput == S7.ScannerOutput, S0.ScannerOutput == S8.ScannerOutput {
        Alternate9Scanner(scanners: (s0, s1, s2, s3, s4, s5, s6, s7, s8))
    }

    public static func buildBlock<S0: Scannable, S1: Scannable, S2: Scannable, S3: Scannable, S4: Scannable, S5: Scannable, S6: Scannable, S7: Scannable, S8: Scannable, S9: Scannable>(
        _ s0: S0, _ s1: S1, _ s2: S2, _ s3: S3, _ s4: S4, _ s5: S5, _ s6: S6, _ s7: S7, _ s8: S8, _ s9: S9
    ) -> Alternate10Scanner<S0.ScannerOutput, S0, S1, S2, S3, S4, S5, S6, S7, S8, S9>
    where S0.ScannerOutput == S1.ScannerOutput, S0.ScannerOutput == S2.ScannerOutput,
          S0.ScannerOutput == S3.ScannerOutput, S0.ScannerOutput == S4.ScannerOutput,
          S0.ScannerOutput == S5.ScannerOutput, S0.ScannerOutput == S6.ScannerOutput,
          S0.ScannerOutput == S7.ScannerOutput, S0.ScannerOutput == S8.ScannerOutput,
          S0.ScannerOutput == S9.ScannerOutput {
        Alternate10Scanner(scanners: (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9))
    }

}
