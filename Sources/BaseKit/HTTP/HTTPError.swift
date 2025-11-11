import Foundation

enum HTTPError: Error, Sendable, Hashable {
    case statusCode(Int)
    case emptyBody
    case noUrl
}
