import Foundation

public struct EmptyParameters: Encodable, Equatable {
    public init() {}
}

public struct EmptyResponse: Codable, Equatable {
    public init() {}
}

public struct EmptyPathComponent {
    public init() {}
}

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

enum HTTPStatusCode {
    static let noContent = 204
    static let successRange: ClosedRange<Int> = 200 ... 299
    static let badRequest = 400
    static let unauthorized = 401
    static let notFound = 404
    static let unprocessableEntity = 422
}

public protocol Request {
    associatedtype Response: Decodable
    associatedtype Parameters: Encodable
    associatedtype PathComponent

    var headers: [String: String] { get }
    var method: HTTPMethod { get }
    var parameters: Parameters { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var baseURL: String { get }
    var path: String { get }
    var wantCache: Bool { get }
    var localDataInterceptor: (Parameters) -> Response? { get }
    var successHandler: (Response) -> Void { get }
    var failureHandler: (Error) -> Void { get }
    var errorMessage: ((_ statusCode: Int) -> String?)? { get }
    var timeoutInterval: TimeInterval { get }
    var fakeAuthError: Bool { get }

    #if DEBUG
    var testDataPath: URL? { get }
    var fakeAPIErrorStatusCode: Int? { get }
    #endif

    init(
        parameters: Parameters,
        pathComponent: PathComponent
    )
}

public extension Request {
    var queryItems: [URLQueryItem]? {
        let query: [URLQueryItem]

        if let p = parameters as? [Encodable] {
            query = p
                .flatMap { param in param.dictionary.map { key, value in
                    URLQueryItem(name: key, value: value?.description ?? "")
                }
                }
        } else {
            query = parameters.dictionary.map { key, value in
                URLQueryItem(name: key, value: value?.description ?? "")
            }
        }
        return query.sorted { first, second -> Bool in
            first.name > second.name
        }
    }

    var body: Data? {
        try? JSONEncoder().encode(parameters)
    }

    var headers: [String: String] { [:] }

    var wantCache: Bool { false }

    var localDataInterceptor: (Parameters) -> Response? { { _ in nil } }

    var successHandler: (Response) -> Void {{ _ in }}

    var failureHandler: (Error) -> Void {{ _ in }}

    var fakeAPIErrorStatusCode: Int? { nil }

    var errorMessage: ((Int) -> String?)? { nil }

    var timeoutInterval: TimeInterval { 20 }

    var fakeAuthError: Bool { false }
}

private extension Encodable {
    var dictionary: [String: CustomStringConvertible?] {
        (
            try? JSONSerialization
                .jsonObject(with: JSONEncoder().encode(self))
        ) as? [String: CustomStringConvertible?] ??
            [:]
    }
}
