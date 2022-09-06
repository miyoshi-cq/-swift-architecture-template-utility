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
    case normal(String), auth(String), unknown, hms(Int), empty, offline, invalid(String)

    public var errorDescription: String? {
        switch self {
        case let .normal(string):
            return string
        case let .auth(string):
            return string
        case .unknown:
            return "エラーが発生しました"
        case .hms:
            return "エラーが発生しました"
        case .empty:
            return "エラーが発生しました"
        case .offline:
            return "オフラインのため、通信に失敗しました。\n通信環境をご確認ください。"
        case let .invalid(message):
            return message
        }
    }
}
