import Foundation

public enum UtilityConfig {
    public static func setup(
        analytics: AnalyticsProvider,
        fakeAPIErrorStatusCode: Int?
    ) {
        Analytics.shared.provider = analytics
        APIClient.fakeAPIErrorStatusCode = fakeAPIErrorStatusCode
    }
}
