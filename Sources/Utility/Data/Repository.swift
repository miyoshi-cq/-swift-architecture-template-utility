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

    func request(
        useTestData: Bool,
        parameters: T.Parameters,
        pathComponent: T.PathComponent
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?)

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

public class Repository<T: Request, C: Client>: Repo {
    private let client = C()

    public required init() {}

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

        self.client.request(item: item, useTestData: useTestData) { result, responseInfo in

            switch result {
            case let .success(value):
                item.successHandler(value)
            case let .failure(error):
                AnalyticsService.shared.log(
                    error.localizedDescription + " " + String(describing: T.self),
                    .error
                )
                item.failureHandler(error)
            }

            completion(result, responseInfo)
        }
    }

    public func request(
        useTestData: Bool,
        parameters: T.Parameters,
        pathComponent: T.PathComponent
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?) {
        let item = T(
            parameters: parameters,
            pathComponent: pathComponent
        )

        let result = await self.client.request(item: item, useTestData: useTestData)

        switch result.0 {
        case let .success(value):
            item.successHandler(value)

        case let .failure(error):
            AnalyticsService.shared.log(
                error.localizedDescription + " " + String(describing: T.self),
                .error
            )
            item.failureHandler(error)
        }

        return result
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
        self.request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: pathComponent,
            completion: completion
        )
    }

    func request(
        useTestData: Bool = false,
        pathComponent: T.PathComponent
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?) {
        await self.request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: pathComponent
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
        self.request(
            useTestData: useTestData,
            parameters: parameters,
            pathComponent: .init(),
            completion: completion
        )
    }

    func request(
        useTestData: Bool = false,
        parameters: T.Parameters
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?) {
        await self.request(
            useTestData: useTestData,
            parameters: parameters,
            pathComponent: .init()
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
        self.request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: .init(),
            completion: completion
        )
    }

    func request(
        useTestData: Bool = false
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?) {
        await self.request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: .init()
        )
    }

    @discardableResult
    func request() -> T.Response? {
        let item = T(parameters: .init(), pathComponent: .init())
        return item.localDataInterceptor(.init())
    }
}
