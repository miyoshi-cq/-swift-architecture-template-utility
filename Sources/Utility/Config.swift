import Foundation

public enum UtilityConfig {
    public static func setup(
        analytics: AnalyticsProvider
    ) {
        Analytics.shared.provider = analytics
    }
}
