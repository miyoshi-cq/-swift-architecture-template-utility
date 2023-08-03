#if !os(macOS)
import CoreLocation
import Foundation

public final class LocationUtility: NSObject {
    private let locationManager = CLLocationManager()

    public static let shared = LocationUtility()

    private var permittedHandler: () -> Void = {}
    private var deniedHandler: () -> Void = {}

    override init() {
        super.init()
        self.locationManager.delegate = self
    }

    public func requestPermission(
        permittedHandler: @escaping () -> Void = {},
        deniedHandler: @escaping () -> Void = {}
    ) {
        self.permittedHandler = permittedHandler
        self.deniedHandler = deniedHandler

        if #available(iOS 14.0, *) {
            switch self.locationManager.authorizationStatus {
            case .authorizedAlways:
                permittedHandler()
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            case .restricted:
                deniedHandler()
            case .denied:
                deniedHandler()
            case .authorizedWhenInUse:
                permittedHandler()
            @unknown default:
                break
            }
        } else {
            fatalError("available in iOS 14.0 or newer")
        }
    }
}

extension LocationUtility: CLLocationManagerDelegate {
    public func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        switch status {
        case .notDetermined:
            break
        case .restricted:
            self.deniedHandler()
        case .denied:
            self.deniedHandler()
        case .authorizedAlways:
            self.permittedHandler()
        case .authorizedWhenInUse:
            self.permittedHandler()
        @unknown default:
            break
        }
    }
}
#endif
