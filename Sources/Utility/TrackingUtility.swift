#if !os(macOS)
import AppTrackingTransparency

public final class TrackingUtility {
    public static func requestPermission() {
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    ATTrackingManager.requestTrackingAuthorization { _ in }
                }
            case .restricted:
                break
            case .denied:
                break
            case .authorized:
                break
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
#endif
