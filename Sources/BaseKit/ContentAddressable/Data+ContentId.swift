import Foundation
import CryptoKit

public extension Data {
    func contentId() -> ContentId {
        ContentId(hashedString())
    }
    
    func hashedString() -> String {
        SHA256.hash(data: self)
            .map { String($0, radix: 16, uppercase: false).leftPadding(toLength: 2, withPad: "0") }
            .joined()
    }
}
