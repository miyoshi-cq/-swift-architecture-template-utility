import Foundation

public protocol AnalyticsProvider {
    func sendEvent(title: String)
    func sendNonFatalError(error: Error)
    func setUserID(userId: String?)
    func log(message: String)
}

public final class Analytics {
    private init() {}

    public static var shared: Analytics = .init()

    var provider: AnalyticsProvider?

    public func sendEvent(title: String = #function) {
        provider?.sendEvent(title: title)
    }

    public func sendNonFatalError(error: Error) {
        provider?.sendNonFatalError(error: error)
    }

    public func setUserID(userId: String?) {
        provider?.setUserID(userId: userId)
    }

    public func log(message: String) {
        provider?.log(message: message)
    }
}
