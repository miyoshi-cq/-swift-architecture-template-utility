import Foundation
import os

public protocol AnalyticsProvider: Sendable {
    func sendEvent(event: AnalyticsEvent)
    func sendScreen(screen: AnalyticsScreen)
    func sendNonFatalError(error: Error)
    func setUserID(userId: String?)
    func log(message: String, function: String, file: String, line: Int)
}

public protocol AnalyticsScreen: Sendable {
    var screenName: String { get }
}

public protocol AnalyticsEvent: Sendable {
    var paramter1: String { get }
    var paramter2: [(type: String, value: String?)] { get }
    var paramter3: Bool { get }
}

public extension AnalyticsEvent {
    var paramter3: Bool { false }
}

public final actor AnalyticsService {
    private init() {}

    public static let shared: AnalyticsService = .init()

    private var providers: [AnalyticsProvider] = []

    public func setProviders(providers: [AnalyticsProvider]) {
        self.providers = providers
    }

    public func sendEvent(_ event: AnalyticsEvent) {
        self.providers.forEach { item in
            item.sendEvent(event: event)
        }
    }

    public func sendScreen(screen: AnalyticsScreen) {
        self.providers.forEach { item in
            item.sendScreen(screen: screen)
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

    public func log(
        _ message: String,
        _ logType: OSLogType = .default,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        LogService.log(message, logType, function: function, file: file, line: line)

        self.providers.forEach { item in
            item.log(message: message, function: function, file: file, line: line)
        }
    }
}
