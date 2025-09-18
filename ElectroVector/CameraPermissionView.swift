import SwiftUI

struct CameraPermissionView: View {
    @ObservedObject var cameraService: CameraService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("Camera Access Required")
                .font(.title)
                .fontWeight(.bold)
            
            Text("ElectroVector needs camera access to capture ECG images for AI-powered analysis.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                if cameraService.canRequestPermission {
                    Button("Grant Camera Access") {
                        cameraService.requestCameraPermission { granted in
                            if granted {
                                dismiss()
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                } else if cameraService.isDenied {
                    Button("Open Settings") {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                }
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            cameraService.checkCameraPermission()
        }
    }
}
