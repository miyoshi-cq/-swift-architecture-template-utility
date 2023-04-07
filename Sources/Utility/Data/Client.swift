import Foundation

public protocol Client: Initializable {
    func request<T: Request>(
        item: T,
        useTestData: Bool
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?)
}
