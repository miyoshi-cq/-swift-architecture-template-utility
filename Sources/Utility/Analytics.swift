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
        self.provider?.sendEvent(title: title)
    }

    public func sendNonFatalError(error: Error) {
        self.provider?.sendNonFatalError(error: error)
    }

    public func setUserID(userId: String?) {
        self.provider?.setUserID(userId: userId)
    }

    public func log(message: String) {
        self.provider?.log(message: message)
    }
}
