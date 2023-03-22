import Foundation

private var instances: [String: AnyObject] = [:]

protocol ActorUsecase: Actor {
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

public actor ActorUsecaseImpl<
    R: Initializable,
    M: Initializable,
    I: Initializable,
    E: Entity
>: ActorUsecase {
    public var repository: R
    public var mapper: M
    public var analytics: AnalyticsService = .shared
    public var useTestData: Bool
    public var inputStorage: I
    public var outputStorage: [E] = []
    public var lastId: String?
    public var xCursol: String?

    public static var shared: some ActorUsecaseImpl {
        let type = String(describing: R.self)
            + String(describing: M.self)
            + String(describing: I.self)
            + String(describing: E.self)

        if let instance = instances[type] as? ActorUsecaseImpl<R, M, I, E> {
            return instance
        }

        let instance = ActorUsecaseImpl<R, M, I, E>(
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
        self.inputStorage = input
        self.useTestData = useTestData

        NotificationCenter.default.addObserver(
            forName: NotificationName.clearUsecase,
            object: nil,
            queue: .current
        ) { [weak self] _ in
            guard let self else { return }

            self.inputStorage = .init()
            self.outputStorage = []
            self.lastId = nil
            self.xCursol = nil
        }
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
}

public extension ActorUsecaseImpl where R: Repo,
    M: MapperProtocol,
    M.Response == R.T.Response,
    M.EntityModel: Sequence,
    M.EntityModel.Element == E
{
    func handleResult(result: (Result<R.T.Response, APIError>, HTTPURLResponse?))
        -> Result<M.EntityModel, AppError>
    {
        self.xCursol = result.1?.allHeaderFields["X-Cursor"] as? String

        switch result.0 {
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

            return .success(entities)

        case let .failure(error):
            return self.handleError(error: error)
        }
    }
}

public extension ActorUsecaseImpl where R: Repo,
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
}

public extension ActorUsecaseImpl where R: Repo, M == EmptyMapper {
    func handleResult(result: (Result<R.T.Response, APIError>, HTTPURLResponse?))
        -> Result<Void, AppError>
    {
        self.xCursol = result.1?.allHeaderFields["X-Cursor"] as? String

        switch result.0 {
        case .success:
            return .success(())

        case let .failure(error):
            return self.handleError(error: error)
        }
    }
}
