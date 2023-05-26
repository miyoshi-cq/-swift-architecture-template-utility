import Foundation

public protocol Repo: Initializable {
    associatedtype T: Request

    func request(
        useTestData: Bool,
        parameters: T.Parameters,
        pathComponent: T.PathComponent
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?)
}

public class Repository<T: Request, C: Client>: Repo {
    private let client = C()

    public required init() {}

    @discardableResult
    public func request(
        useTestData: Bool = false,
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
            AnalyticsService.log(
                error.localizedDescription + " " + String(describing: T.self),
                .error
            )
            item.failureHandler(error)
        }

        if let localDataInterceptorResult = await item.localDataInterceptor(parameters) {
            return (.success(localDataInterceptorResult), nil)
        } else {
            return result
        }
    }
}

public extension Repository where T.Parameters == EmptyParameters {
    @discardableResult
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
}

public extension Repository where T.PathComponent == EmptyPathComponent {
    @discardableResult
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
}

public extension Repository where T.PathComponent == EmptyPathComponent,
    T.Parameters == EmptyParameters
{
    @discardableResult
    func request(
        useTestData: Bool = false
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?) {
        await self.request(
            useTestData: useTestData,
            parameters: .init(),
            pathComponent: .init()
        )
    }
}
