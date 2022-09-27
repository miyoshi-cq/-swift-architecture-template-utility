import Combine
import Foundation

public enum NotificationName {
    public static let clearOutputStorage: Notification.Name = .init(rawValue: "outputStorage.clear")
}

private var instances: [String: AnyObject] = [:]

protocol Usecase {
    associatedtype Repository: Initializable
    associatedtype Mapper: Initializable
    associatedtype Input: Initializable
    associatedtype Output: Entity

    var repository: Repository { get }
    var mapper: Mapper { get }
    var analytics: Analytics { get }
    var inputStorage: Input { get }
    var outputStorage: [Output] { get }
    var lastId: String? { get }
    var xCursol: String? { get }
}

public class UsecaseImpl<R: Initializable, M: Initializable, I: Initializable, E: Entity>: Usecase {
    public var repository: R
    public var mapper: M
    public var analytics: Analytics = .shared
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
        analytics: Analytics = .shared,
        useTestData: Bool
    ) {
        self.repository = repository
        self.mapper = mapper
        self.analytics = analytics
        self.useTestData = useTestData
        inputStorage = input

        NotificationCenter.default.addObserver(
            forName: NotificationName.clearOutputStorage,
            object: nil,
            queue: .current
        ) { _ in
            self.outputStorage = []
        }
    }

    public func toPublisher<T, E: Error>(
        closure: @escaping (@escaping Future<T, E>.Promise) -> Void
    ) -> AnyPublisher<T, E> {
        Deferred {
            Future { [weak self] promise in
                self?.analytics.log(message: String(describing: self))
                closure(promise)
            }
        }.eraseToAnyPublisher()
    }

    public func handleError<T>(error: APIError, promise: Future<T, AppError>.Promise) {
        analytics
            .log(message: "\(String(describing: self)): Fail: \(error.localizedDescription)")

        switch error {
        case .unknown, .missingTestJsonDataPath, .invalidRequest, .decodeError:
            promise(.failure(.none))

        case .offline:
            promise(.failure(.normal(title: "", message: error.localizedDescription)))

        case let .responseError(statusCode):

            switch statusCode {
            case 401, 403:
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

                self?.analytics.log(message: String(describing: self))

                var completion: (Result<R.T.Response, APIError>, HTTPURLResponse?)
                    -> Void
                { { [weak self] result, info in

                    guard let self = self else { return }

                    self.xCursol = info?.allHeaderFields["X-Cursor"] as? String

                    switch result {
                    case let .success(response):
                        self.analytics.log(message: "\(String(describing: self)): Success")

                        let entities = self.mapper.convert(response: response)

                        entities.forEach { entity in
                            let index = self.outputStorage
                                .firstIndex { element in element == entity }
                            if let index = index {
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
    func toPublisher(
        closure: @escaping (@escaping (Result<R.T.Response, APIError>, HTTPURLResponse?) -> Void)
            -> Void
    ) -> AnyPublisher<M.EntityModel, AppError> {
        Deferred {
            Future { [weak self] promise in

                self?.analytics.log(message: String(describing: self))

                var completion: (Result<R.T.Response, APIError>, HTTPURLResponse?)
                    -> Void
                { { [weak self] result, info in

                    guard let self = self else { return }

                    self.xCursol = info?.allHeaderFields["X-Cursor"] as? String

                    switch result {
                    case let .success(response):
                        self.analytics.log(message: "\(String(describing: self)): Success")

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

                self?.analytics.log(message: String(describing: self))

                var completion: (Result<EmptyResponse, APIError>, HTTPURLResponse?)
                    -> Void
                { { [weak self] result, info in

                    guard let self = self else { return }

                    self.xCursol = info?.allHeaderFields["X-Cursor"] as? String

                    switch result {
                    case .success:
                        self.analytics.log(message: "\(String(describing: self)): Success")

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
