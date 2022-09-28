import Foundation

public struct TestDataFetchRequest {
    private let testDataJsonPath: URL?

    public init(testDataJsonPath: URL?) {
        self.testDataJsonPath = testDataJsonPath
    }

    public func fetchLocalTestData<T: Decodable>(responseType _: T.Type) -> Result<T, APIError> {
        do {
            if let result = EmptyResponse() as? T {
                return Result.success(result)
            }

            guard let url = testDataJsonPath else {
                return Result.failure(.missingTestJsonDataPath)
            }
            let data = try Data(contentsOf: url)
            let result = try JSONDecoder().decode(T.self, from: data)
            return Result.success(result)
        } catch {
            #if DEBUG
            debugPrint(error)
            #endif
            return Result.failure(.decodeError(error.localizedDescription))
        }
    }
}
