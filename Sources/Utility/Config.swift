import Foundation
import os

public enum UtilityConfig {
    public static func setup(
        analytics: [AnalyticsProvider],
        subsystem: String
    ) {
        Task.detached {
            await AnalyticsService.shared.setProviders(providers: analytics)
        }
        LogService.logger = Logger(subsystem: subsystem, category: "Default")
    }
}
