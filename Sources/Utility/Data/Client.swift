import Foundation

public protocol Client: Initializable {
    /// API request
    /// - Parameters:
    ///   - item: Request setting
    ///   - useTestData: use test data or not
    /// - Returns: result of response
    func request<T: Request>(
        item: T,
        useTestData: Bool
    ) async -> (Result<T.Response, APIError>, HTTPURLResponse?)
}
