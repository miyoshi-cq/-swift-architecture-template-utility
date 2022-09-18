import Foundation

public protocol Repo: Initializable {
    associatedtype T: Request

    /// Except for LocalRequest, e.g. AppRequest
    /// - Parameters:
    ///   - useTestData: if this is true, use stub data
    ///   - parameters: parameter for api request
    ///   - pathComponent: path component for api request
    ///   - completion: success or failure
    func request(
        useTestData: Bool,
        parameters: T.Parameters,
        pathComponent: T.PathComponent,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    )

    /// For LocalRequest
    /// - Parameters:
    ///   - parameters: parameter
    ///   - pathComponent: path component
    /// - Returns: response
    func request(
        parameters: T.Parameters,
        pathComponent: T.PathComponent
    ) -> T.Response?
}

public struct Repository<T: Request, C: Client>: Repo {
    private let client = C()

    public init() {}

    public func request(
        useTestData: Bool = false,
        parameters: T.Parameters,
        pathComponent: T.PathComponent,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    ) {
        let item = T(
            parameters: parameters,
            pathComponent: pathComponent
        )

        client.request(item: item, useTestData: useTestData) { result, responseInfo in

            switch result {
            case let .success(value):
                item.successHandler(value)
            case let .failure(error):
                item.failureHandler(error)
            }

            completion(result, responseInfo)
        }
    }

    @discardableResult
    public func request(
        parameters: T.Parameters,
        pathComponent: T.PathComponent
    ) -> T.Response? {
        let item = T(parameters: parameters, pathComponent: pathComponent)
        return item.localDataInterceptor(parameters)
    }
}

public extension Repository where T.Parameters == EmptyParameters {
    func request(
        useTestData: Bool = false,
        pathComponent: T.PathComponent,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    ) {
        request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: pathComponent,
            completion: completion
        )
    }

    @discardableResult
    func request(
        pathComponent: T.PathComponent
    ) -> T.Response? {
        let item = T(parameters: .init(), pathComponent: pathComponent)
        return item.localDataInterceptor(.init())
    }
}

public extension Repository where T.PathComponent == EmptyPathComponent {
    func request(
        useTestData: Bool = false,
        parameters: T.Parameters,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    ) {
        request(
            useTestData: useTestData,
            parameters: parameters,
            pathComponent: .init(),
            completion: completion
        )
    }

    @discardableResult
    func request(
        parameters: T.Parameters
    ) -> T.Response? {
        let item = T(parameters: parameters, pathComponent: .init())
        return item.localDataInterceptor(parameters)
    }
}

public extension Repository where T.PathComponent == EmptyPathComponent,
    T.Parameters == EmptyParameters
{
    func request(
        useTestData: Bool = false,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    ) {
        request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: .init(),
            completion: completion
        )
    }

    @discardableResult
    func request() -> T.Response? {
        let item = T(parameters: .init(), pathComponent: .init())
        return item.localDataInterceptor(.init())
    }
}
