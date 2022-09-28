import Foundation

public enum APIError: Equatable, Error {
    case unknown
    case missingTestJsonDataPath
    case invalidRequest
    case offline
    case decodeError(String)
    case responseError(statusCode: Int, errorMessage: String?)
}
