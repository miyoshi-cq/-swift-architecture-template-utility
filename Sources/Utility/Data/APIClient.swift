import Foundation

public class APIClient: Client {
    public required init() {}

    public func request<T: Request>(
        item: T,
        useTestData: Bool = false
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?) {
        await withCheckedContinuation { continuation in
            self.request(item: item, useTestData: useTestData) { result, response in
                continuation.resume(returning: (result, response))
            }
        }
    }

    public func request<T: Request>(
        item: T,
        useTestData: Bool = false,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    ) {
        #if DEBUG
        if useTestData {
            let testDataFetchRequest = TestDataFetchRequest(testDataJsonPath: item.testDataPath)
            completion(
                testDataFetchRequest.fetchLocalTestData(responseType: T.Response.self),
                nil
            )
            return
        }
        #endif

        #if DEBUG
        let configuration = URLSessionConfiguration.default
        if let fakeAPIErrorStatusCode = item.fakeAPIErrorStatusCode {
            configuration.protocolClasses = [MockURLProtocol.self]
            MockURLProtocol.requestHandler = { request in
                let mockJSONData = "{\"messages\":[\"認証トークンが確認できませんでした。\"]}".data(using: .utf8)!
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: fakeAPIErrorStatusCode,
                    httpVersion: "HTTP/1.1",
                    headerFields: nil
                )
                return (response, mockJSONData)
            }
        }
        let urlSession = URLSession(configuration: configuration)
        #else
        let urlSession = URLSession.shared
        #endif

        urlSession.sessionDescription = String(describing: T.self)

        guard var urlRequest = createURLRequest(item) else {
            completion(.failure(.invalidRequest), nil)
            return
        }

        guard item.fakeAuthError == false else {
            completion(
                .failure(
                    .responseError(
                        statusCode: 401,
                        errorMessage: nil
                    )
                ),
                nil
            )
            return
        }

        guard item.fakeBadRequestError == false else {
            completion(
                .failure(
                    .responseError(
                        statusCode: 400,
                        errorMessage: item.errorMessage?(400)
                    )
                ),
                nil
            )
            return
        }

        urlRequest.timeoutInterval = item.timeoutInterval

        // TODO: need to consider cache expiration
        if let cache = URLCache.shared.cachedResponse(for: urlRequest), item.wantCache {
            self.decode(data: cache.data, responseInfo: nil, completion: completion)
            return
        }

        let task = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in

            guard let self else {
                completion(.failure(.unknown), nil)
                return
            }

            if let error {
                AnalyticsService.log(error.localizedDescription, .error)
            }

            #if DEBUG
            if let response {
                debugPrint(response)
            }

            if item.fakeTimeoutError {
                completion(.failure(.timeout), response as? HTTPURLResponse)
                return
            }

            #endif

            if
                let err = error as NSError?,
                err.domain == NSURLErrorDomain
            {
                switch err.code {
                case NSURLErrorNotConnectedToInternet:
                    completion(.failure(.offline), response as? HTTPURLResponse)
                    return

                case NSURLErrorTimedOut:
                    completion(.failure(.timeout), response as? HTTPURLResponse)
                    return

                default:
                    break
                }
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(.unknown), response as? HTTPURLResponse)
                return
            }

            switch statusCode {
            case HTTPStatusCode.successRange:
                guard let data else {
                    completion(.failure(.unknown), response as? HTTPURLResponse)
                    return
                }

                self.decode(
                    data: data,
                    responseInfo: response as? HTTPURLResponse,
                    completion: completion
                )

            default:
                completion(
                    .failure(
                        .responseError(
                            statusCode: statusCode,
                            errorMessage: item.errorMessage?(statusCode)
                        )
                    ),
                    response as? HTTPURLResponse
                )
            }
        }

        task.taskDescription = String(describing: T.self)
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

    private func createURLRequest(_ requestItem: some Request) -> URLRequest? {
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

        let curl = urlRequest.curlString

        AnalyticsService.log(curl)

        return urlRequest
    }
}
