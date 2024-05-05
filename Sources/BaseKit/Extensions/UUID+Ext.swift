import Foundation

extension UUID: Comparable {
    public static func < (lhs: UUID, rhs: UUID) -> Bool {
        lhs.uuidString < rhs.uuidString
    }
}
