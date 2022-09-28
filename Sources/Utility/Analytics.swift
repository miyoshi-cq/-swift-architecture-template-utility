import Foundation

public protocol AnalyticsProvider {
    func sendEvent(event: AnalyticsEvent)
    func sendScreen(screenName: String)
    func sendNonFatalError(error: Error)
    func setUserID(userId: String?)
    func log(message: String)
}

public struct AnalyticsEvent {
    public let category: String
    public let action: String
    public let label: String

    public init(
        category: String,
        action: String,
        label: String
    ) {
        self.category = category
        self.action = action
        self.label = label
    }
}

public final class AnalyticsService {
    private init() {}

    public static var shared: AnalyticsService = .init()

    var provider: AnalyticsProvider?

    public func sendEvent(_ event: AnalyticsEvent) {
        self.provider?.sendEvent(event: event)
    }

    public func sendScreen(screenName: String) {
        self.provider?.sendScreen(screenName: screenName)
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
