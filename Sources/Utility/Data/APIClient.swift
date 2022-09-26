import Foundation

public struct APIClient: Client {
    public init() {}

    public func request<T: Request>(
        item: T,
        useTestData: Bool = false,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    ) {
        #if DEBUG
            if useTestData {
                let testDataFetchRequest = TestDataFetchRequest(testDataJsonPath: item.testDataPath)
                completion(testDataFetchRequest.fetchLocalTestData(responseType: T.Response.self), nil)
                return
            }
        #endif

        guard let urlRequest = createURLRequest(item) else {
            completion(.failure(.invalidRequest), nil)
            return
        }

        // TODO: need to consider cache expiration
        if let cache = URLCache.shared.cachedResponse(for: urlRequest), item.wantCache {
            decode(data: cache.data, responseInfo: nil, completion: completion)
            return
        }

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, _ in

            // TODO: 暫定でステータスコードによる判定処理を追加。使用しない場合削除
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                switch statusCode {
                case HTTPStatusCode.noContent: // 204
                    Logger.debug(message: "status code is noContent(\(statusCode))")
                case HTTPStatusCode.successRange: // 200...299
                    Logger.debug(message: "status code is success(\(statusCode))")
                case HTTPStatusCode.badRequest: // 400
                    Logger.debug(message: "status code is bad request(\(statusCode))")
                case HTTPStatusCode.unauthorized: // 401
                    Logger.debug(message: "status code is unauthorized(\(statusCode))")
                case HTTPStatusCode.notFound: // 404
                    Logger.debug(message: "status code is notFound(\(statusCode))")
                case HTTPStatusCode.unprocessableEntity: // 422
                    Logger.debug(message: "status code is unprocessableEntity(\(statusCode))")
                default: // 上記以外
                    Logger.debug(message: "status code: \(statusCode)")
                }
            } else {
                Logger.debug(message: "status code is nil")
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(.unknown), response as? HTTPURLResponse)
                return
            }

            switch statusCode {
            case HTTPStatusCode.successRange:
                guard let data = data else {
                    completion(.failure(.unknown), response as? HTTPURLResponse)
                    return
                }

                decode(
                    data: data,
                    responseInfo: response as? HTTPURLResponse,
                    completion: completion
                )

            default:
                completion(
                    .failure(.responseError(statusCode: statusCode)),
                    response as? HTTPURLResponse
                )
            }
        }

        task.resume()
    }

    private func decode<T: Decodable>(
        data: Data,
        responseInfo: HTTPURLResponse?,
        completion: @escaping (Result<T, APIError>, HTTPURLResponse?) -> Void
    ) {
        do {
            if let result = EmptyResponse() as? T {
                completion(.success(result), responseInfo)
            } else {
                let value = try JSONDecoder().decode(T.self, from: data)
                completion(.success(value), responseInfo)
            }
        } catch {
            debugPrint(error)
            completion(.failure(.decodeError(error.localizedDescription)), responseInfo)
        }
    }

    private func createURLRequest<R: Request>(_ requestItem: R) -> URLRequest? {
        guard let fullPath = URL(string: requestItem.baseURL + requestItem.path) else { return nil }

        var urlComponents = URLComponents()

        urlComponents.scheme = fullPath.scheme
        urlComponents.host = fullPath.host
        urlComponents.path = fullPath.path
        urlComponents.port = fullPath.port
        urlComponents.queryItems = requestItem.queryItems

        guard let url = urlComponents.url else { return nil }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = requestItem.method.rawValue
        urlRequest.httpBody = requestItem.body

        requestItem.headers.forEach { urlRequest.addValue($1, forHTTPHeaderField: $0) }

        Logger.debug(message: urlRequest.curlString)

        return urlRequest
    }
}
