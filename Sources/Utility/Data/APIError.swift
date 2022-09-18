import Foundation

public enum APIError: LocalizedError, Equatable {
    case unknown
    case missingTestJsonDataPath
    case invalidRequest
    case offline
    case authError
    case decodeError(String)
    case responseError

    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "unknown error occured"
        case .missingTestJsonDataPath:
            return "missing test json data path"
        case .invalidRequest:
            return "invalid request"
        case .offline:
            return "offline error occured"
        case let .decodeError(error):
            return "decode error occured, \(error)"
        case .responseError:
            return "response error occured"
        case .authError:
            return "auth error occured"
        }
    }
}
