import Foundation

public struct UtilityConfig {
    public static func setup(analytics: AnalyticsProvider) {
        Analytics.shared.provider = analytics
    }
}
