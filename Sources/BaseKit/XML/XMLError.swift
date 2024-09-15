import Foundation

public enum XMLError: Error {
    case parsingError(Error?)
    case valueNotFound(XMLID)
    case commandFailed(String, Error)
    case invalidElement
    case notAnElement
    case indexOutOfBounds
    case upsertFailedToCreateElement
}
