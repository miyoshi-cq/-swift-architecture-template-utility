import Foundation
import os

public enum UtilityConfig {
    public static func setup(
        analytics: [AnalyticsProvider],
        subsystem: String
    ) {
        AnalyticsService.shared.providers = analytics
        LogService.logger = Logger(subsystem: subsystem, category: "Default")
    }
}
