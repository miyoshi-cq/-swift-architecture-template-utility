import Foundation
import os

public enum UtilityConfig {
    public static func setup(
        analytics: [AnalyticsProvider],
        subsystem: String
    ) {
        AnalyticsService.setProviders(providers: analytics)
        if #available(iOS 14.0, *) {
            LogService.logger = Logger(subsystem: subsystem, category: "Default")
        }
    }
}
