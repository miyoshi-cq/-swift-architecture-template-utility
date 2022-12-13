import Foundation

public protocol LocalRequest: Request {}

public extension LocalRequest {
    var baseURL: String { "" }
    var method: HTTPMethod { fatalError() }
    var parameters: Parameters { fatalError() }
    var path: String { "" }
    var testDataPath: URL? { nil }
}
