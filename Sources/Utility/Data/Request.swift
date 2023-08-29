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

/// Request for API Client
public protocol Request {
    /// API response type
    associatedtype Response: Decodable
    associatedtype Parameters: Encodable
    associatedtype PathComponent

    /// http request header infomation
    var headers: [String: String] { get }
    /// http method
    var method: HTTPMethod { get }
    /// nessesary for creating request url
    var parameters: Parameters { get }
    /// http query
    var queryItems: [URLQueryItem]? { get }
    /// http body
    var body: Data? { get }
    /// base url
    var baseURL: String { get }
    /// request url path
    var path: String { get }
    /// use cache or not
    var wantCache: Bool { get }
    /// middleware
    var localDataInterceptor: (Parameters) async -> Response? { get }
    /// called when request succeed
    var successHandler: (Response) -> Void { get }
    /// called when request fail
    var failureHandler: (Error) -> Void { get }
    /// error message for each status code
    var errorMessage: ((_ statusCode: Int) async -> String?)? { get }
    /// timeout interval
    var timeoutInterval: TimeInterval { get }
    /// fake auth error or not
    var fakeAuthError: Bool { get }
    /// fake timeout error or not
    var fakeTimeoutError: Bool { get }
    /// fake bad request  error or not
    var fakeBadRequestError: Bool { get async }

    #if DEBUG
    /// local test data url
    var testDataPath: URL? { get }
    /// fake status code
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

    var localDataInterceptor: (Parameters) async -> Response? { { _ in nil } }

    var successHandler: (Response) -> Void {{ _ in }}

    var failureHandler: (Error) -> Void {{ _ in }}

    var fakeAPIErrorStatusCode: Int? { nil }

    var errorMessage: ((Int) async -> String?)? { nil }

    var timeoutInterval: TimeInterval { 10 }

    var fakeAuthError: Bool { false }

    var fakeTimeoutError: Bool { false }

    var fakeBadRequestError: Bool { false }
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
