import Foundation

public enum UtilityConfig {
    public static func setup(
        analytics: AnalyticsProvider
    ) {
        AnalyticsService.shared.provider = analytics
    }
}
