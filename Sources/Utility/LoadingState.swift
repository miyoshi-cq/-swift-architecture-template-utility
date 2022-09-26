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

public enum AppError: Error, Equatable, LocalizedError {
    case notice(title: String, message: String),
         redirect(title: String, message: String),
         none

    public var errorDescription: String? {
        switch self {
        case let .notice(_, message):
            return message
        case let .redirect(_, message):
            return message
        case .none:
            return nil
        }
    }
}
