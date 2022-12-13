import Combine
import Foundation

public enum NotificationName {
    public static let clearUsecase: Notification.Name = .init(rawValue: "usecase.clear")
}

private var instances: [String: AnyObject] = [:]

protocol Usecase {
    associatedtype Repository: Initializable
    associatedtype Mapper: Initializable
    associatedtype Input: Initializable
    associatedtype Output: Entity

    var repository: Repository { get }
    var mapper: Mapper { get }
    var analytics: AnalyticsService { get }
    var inputStorage: Input { get }
    var outputStorage: [Output] { get }
    var lastId: String? { get }
    var xCursol: String? { get }
}

public class UsecaseImpl<R: Initializable, M: Initializable, I: Initializable, E: Entity>: Usecase {
    public var repository: R
    public var mapper: M
    public var analytics: AnalyticsService = .shared
    public var useTestData: Bool
    public var inputStorage: I
    public var outputStorage: [E] = []
    public var lastId: String?
    public var xCursol: String?

    public static var shared: some UsecaseImpl {
        let type = String(describing: R.self)
            + String(describing: M.self)
            + String(describing: I.self)
            + String(describing: E.self)

        if let instance = instances[type] as? UsecaseImpl<R, M, I, E> {
            return instance
        }

        let instance = UsecaseImpl<R, M, I, E>(
            repository: .init(),
            mapper: .init(),
            input: .init(),
            useTestData: false
        )
        instances[type] = instance
        return instance
    }

    private init(
        repository: R,
        mapper: M,
        input: I,
        analytics: AnalyticsService = .shared,
        useTestData: Bool
    ) {
        self.repository = repository
        self.mapper = mapper
        self.analytics = analytics
        self.useTestData = useTestData
        self.inputStorage = input

        NotificationCenter.default.addObserver(
            forName: NotificationName.clearUsecase,
            object: nil,
            queue: .current
        ) { _ in
            self.inputStorage = .init()
            self.outputStorage = []
            self.lastId = nil
            self.xCursol = nil
        }
    }

    public func toPublisher<T, E: Error>(
        closure: @escaping (@escaping Future<T, E>.Promise) -> Void
    ) -> AnyPublisher<T, E> {
        Deferred {
            Future { promise in
                closure(promise)
            }
        }.eraseToAnyPublisher()
    }

    public func handleError<T>(error: APIError) -> Result<T, AppError> {
        switch error {
        case .unknown, .missingTestJsonDataPath, .invalidRequest, .decodeError:
            return .failure(.none)

        case .offline, .timeout:
            return .failure(.normal(title: "", message: error.localizedDescription))

        case let .responseError(statusCode, _):

            switch statusCode {
            case 401, 403:

                NotificationCenter.default.post(
                    name: NotificationName.clearUsecase,
                    object: nil
                )

                return .failure(.auth(title: "", message: error.localizedDescription))
            default:
                return .failure(.normal(title: "", message: error.localizedDescription))
            }
        }
    }

    public func handleError<T>(error: APIError, promise: Future<T, AppError>.Promise) {
        switch error {
        case .unknown, .missingTestJsonDataPath, .invalidRequest, .decodeError:
            promise(.failure(.none))

        case .offline, .timeout:
            promise(.failure(.normal(title: "", message: error.localizedDescription)))

        case let .responseError(statusCode, _):

            switch statusCode {
            case 401, 403:

                NotificationCenter.default.post(
                    name: NotificationName.clearUsecase,
                    object: nil
                )

                promise(.failure(.auth(title: "", message: error.localizedDescription)))
            default:
                promise(.failure(.normal(title: "", message: error.localizedDescription)))
            }
        }
    }
}

public extension UsecaseImpl where R: Repo,
    M: MapperProtocol,
    M.Response == R.T.Response,
    M.EntityModel: Sequence,
    M.EntityModel.Element == E
{
    func toPublisher(
        closure: @escaping (@escaping (Result<R.T.Response, APIError>, HTTPURLResponse?) -> Void)
            -> Void
    ) -> AnyPublisher<M.EntityModel, AppError> {
        Deferred {
            Future { [weak self] promise in
                var completion: (Result<R.T.Response, APIError>, HTTPURLResponse?)
                    -> Void
                { { [weak self] result, info in

                    guard let self else { return }

                    self.xCursol = info?.allHeaderFields["X-Cursor"] as? String

                    switch result {
                    case let .success(response):
                        let entities = self.mapper.convert(response: response)

                        entities.forEach { entity in
                            let index = self.outputStorage
                                .firstIndex { element in element == entity }
                            if let index {
                                self.outputStorage.remove(at: index)
                            }
                            self.outputStorage.append(entity)
                        }

                        promise(.success(entities))
                    case let .failure(error):
                        self.handleError(error: error, promise: promise)
                    }
                }}

                closure(completion)
            }
        }.eraseToAnyPublisher()
    }
}

public extension UsecaseImpl where R: Repo,
    M: MapperProtocol,
    M.Response == R.T.Response,
    M.EntityModel == E
{
    func handleResult(result: (Result<R.T.Response, APIError>, HTTPURLResponse?))
        -> Result<M.EntityModel, AppError>
    {
        self.xCursol = result.1?.allHeaderFields["X-Cursor"] as? String

        switch result.0 {
        case let .success(response):
            let entity = self.mapper.convert(response: response)
            self.outputStorage = [entity]
            return .success(entity)

        case let .failure(error):
            return self.handleError(error: error)
        }
    }

    func toPublisher(
        closure: @escaping (@escaping (Result<R.T.Response, APIError>, HTTPURLResponse?) -> Void)
            -> Void
    ) -> AnyPublisher<M.EntityModel, AppError> {
        Deferred {
            Future { [weak self] promise in
                var completion: (Result<R.T.Response, APIError>, HTTPURLResponse?)
                    -> Void
                { { [weak self] result, info in

                    guard let self else { return }

                    self.xCursol = info?.allHeaderFields["X-Cursor"] as? String

                    switch result {
                    case let .success(response):
                        let entity = self.mapper.convert(response: response)
                        self.outputStorage = [entity]
                        promise(.success(entity))
                    case let .failure(error):
                        self.handleError(error: error, promise: promise)
                    }
                }}

                closure(completion)
            }
        }.eraseToAnyPublisher()
    }
}

public extension UsecaseImpl where R: Repo, M == EmptyMapper {
    func toPublisher(
        closure: @escaping (@escaping (Result<EmptyResponse, APIError>, HTTPURLResponse?) -> Void)
            -> Void
    ) -> AnyPublisher<Void, AppError> {
        Deferred {
            Future { [weak self] promise in
                var completion: (Result<EmptyResponse, APIError>, HTTPURLResponse?)
                    -> Void
                { { [weak self] result, info in

                    guard let self else { return }

                    self.xCursol = info?.allHeaderFields["X-Cursor"] as? String

                    switch result {
                    case .success:
                        promise(.success(()))
                    case let .failure(error):
                        self.handleError(error: error, promise: promise)
                    }
                }}

                closure(completion)
            }
        }.eraseToAnyPublisher()
    }
}
