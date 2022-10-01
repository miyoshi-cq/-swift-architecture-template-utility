import Foundation

public protocol AnalyticsProvider {
    func sendEvent(event: AnalyticsEvent)
    func sendScreen(screenName: String)
    func sendNonFatalError(error: Error)
    func setUserID(userId: String?)
    func log(message: String)
}

public protocol AnalyticsEvent {
    var category: String { get }
    var action: String { get }
    var label: String? { get }
}

public final class AnalyticsService {
    private init() {}

    public static var shared: AnalyticsService = .init()

    var providers: [AnalyticsProvider] = []

    public func sendEvent(_ event: AnalyticsEvent) {
        self.providers.forEach { item in
            item.sendEvent(event: event)
        }
    }

    public func sendScreen(screenName: String) {
        self.providers.forEach { item in
            item.sendScreen(screenName: screenName)
        }
    }

    public func sendNonFatalError(error: Error) {
        self.providers.forEach { item in
            item.sendNonFatalError(error: error)
        }
    }

    public func setUserID(userId: String?) {
        self.providers.forEach { item in
            item.setUserID(userId: userId)
        }
    }

    public func log(message: String) {
        self.providers.forEach { item in
            item.log(message: message)
        }
    }
}
