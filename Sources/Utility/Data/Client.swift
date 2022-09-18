import Foundation

public protocol Client: Initializable {
    func request<T: Request>(
        item: T,
        useTestData: Bool,
        completion: @escaping (Result<T.Response, APIError>, HTTPURLResponse?) -> Void
    )
}
