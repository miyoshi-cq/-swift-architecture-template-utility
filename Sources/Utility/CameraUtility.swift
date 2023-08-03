#if !os(macOS)
import AVFoundation
import Foundation

public class CameraUtility {
    public static func requestPermission(completion: @escaping (AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(.authorized)

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        completion(.authorized)
                    } else {
                        completion(.denied)
                    }
                }
            }

        case .denied:
            completion(.denied)

        case .restricted:
            completion(.restricted)

        @unknown default:
            break
        }
    }
}
#endif
