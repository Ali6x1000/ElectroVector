import AVFoundation
import UIKit

class CameraService: ObservableObject {
    @Published var isAuthorized = false
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    init() {
        checkCameraPermission()
    }
    
    func checkCameraPermission() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = false
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch authorizationStatus {
        case .notDetermined:
            // First time - request permission
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    self?.authorizationStatus = granted ? .authorized : .denied
                    completion(granted)
                }
            }
        case .denied:
            // Previously denied - need to go to settings
            DispatchQueue.main.async {
                completion(false)
            }
        case .authorized:
            // Already authorized
            DispatchQueue.main.async {
                self.isAuthorized = true
                completion(true)
            }
        case .restricted:
            // Restricted by parental controls
            DispatchQueue.main.async {
                completion(false)
            }
        @unknown default:
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    var canRequestPermission: Bool {
        return authorizationStatus == .notDetermined
    }
    
    var isDenied: Bool {
        return authorizationStatus == .denied
    }
}
