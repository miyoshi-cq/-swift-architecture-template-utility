#if !os(macOS)
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

public protocol AnalyticsEvent: Sendable, CustomDebugStringConvertible {
    var paramter1: String { get }
    var paramter2: [(type: String, value: String?)] { get }
    var paramter3: Bool { get }
}

public extension AnalyticsEvent {
    var paramter3: Bool { false }

    var debugDescription: String {
        Mirror(reflecting: self).children.map { child in
            "\(child.label ?? ""): \(child.value)"
        }.compactMap { $0 }.joined(separator: " ")
    }
}

public final actor AnalyticsService {
    private init() {}

    static let shared: AnalyticsService = .init()

    private var providers: [AnalyticsProvider] = []

    private func setProviders(providers: [AnalyticsProvider]) {
        self.providers = providers
    }

    private func sendEvent(_ event: AnalyticsEvent) {
        if #available(iOS 14, *) {
            LogService.log(event.debugDescription)
        }

        self.providers.forEach { item in
            item.sendEvent(event: event)
        }
    }

    private func sendScreen(screen: AnalyticsScreen) {
        self.providers.forEach { item in
            item.sendScreen(screen: screen)
        }
    }

    private func sendNonFatalError(error: Error) {
        self.providers.forEach { item in
            item.sendNonFatalError(error: error)
        }
    }

    private func setUserID(userId: String?) {
        self.providers.forEach { item in
            item.setUserID(userId: userId)
        }
    }

    private func log(
        _ message: String,
        _ logType: OSLogType = .default,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        if #available(iOS 14, *) {
            LogService.log(message, logType, function: function, file: file, line: line)
        }

        self.providers.forEach { item in
            item.log(message: message, function: function, file: file, line: line)
        }
    }
}

public extension AnalyticsService {
    static func setProviders(providers: [AnalyticsProvider]) {
        Task.detached {
            await AnalyticsService.shared.setProviders(providers: providers)
        }
    }

    static func sendEvent(_ event: AnalyticsEvent) {
        Task.detached {
            await AnalyticsService.shared.sendEvent(event)
        }
    }

    static func sendScreen(screen: AnalyticsScreen) {
        Task.detached {
            await AnalyticsService.shared.sendScreen(screen: screen)
        }
    }

    static func sendNonFatalError(error: Error) {
        Task.detached {
            await AnalyticsService.shared.sendNonFatalError(error: error)
        }
    }

    static func setUserID(userId: String?) {
        Task.detached {
            await AnalyticsService.shared.setUserID(userId: userId)
        }
    }

    static func log(
        _ message: String,
        _ logType: OSLogType = .default,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) {
        Task.detached {
            await AnalyticsService.shared.log(
                message,
                logType,
                function: function,
                file: file,
                line: line
            )
        }
    }
}
#endif
