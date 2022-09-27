import Foundation

public enum LoadingState<T: Equatable, E: Error & Equatable>: Equatable {
    case standby(T? = nil)
    case loading(T? = nil)
    case failed(E)
    case done(T)
    case addtionalDone(T)

    public var value: T? {
        switch self {
        case let .standby(data): return data
        case let .done(data): return data
        case let .loading(data): return data
        case let .addtionalDone(data): return data
        default: return nil
        }
    }
}
