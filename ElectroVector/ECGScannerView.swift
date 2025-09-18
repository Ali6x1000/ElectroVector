import SwiftUI
import AVFoundation

struct ECGScannerView: View {
    @StateObject private var cameraService = CameraService()
    @StateObject private var ecgService = ECGService()
    @State private var isScanning = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isProcessing = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                headerView
                
                // ECG Monitor
                ecgMonitorView
                
                // Controls
                controlsView
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            if cameraService.isAuthorized {
                CameraView(cameraService: cameraService) { image in
                    capturedImage = image
                    uploadImage(image)
                }
            } else {
                CameraPermissionView(cameraService: cameraService)
            }
        }
        .alert("ECG Analysis", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
            Button("Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This app needs camera access to capture ECG images for analysis. Please enable camera permission in Settings.")
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .symbolEffect(.pulse, isActive: isScanning)
            
            Text("ElectroVector")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("AI-Powered ECG Analysis")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var ecgMonitorView: some View {
        VStack(spacing: 20) {
            // Heart Rate Display
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("\(ecgService.heartRate) BPM")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            // ECG Waveform
            ECGWaveformView(isActive: isScanning, ecgService: ecgService)
                .frame(height: 150)
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.green, lineWidth: 2)
                )
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
    
    private var controlsView: some View {
        VStack(spacing: 20) {
            // Scan Button
            Button(action: toggleScanning) {
                HStack {
                    Image(systemName: isScanning ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                    Text(isScanning ? "Stop Monitoring" : "Start Monitoring")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isScanning ? Color.red : Color.blue)
                .cornerRadius(15)
            }
            
            // Camera Button
            Button(action: handleCameraButtonTap) {
                HStack {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                    }
                    Text(isProcessing ? "Processing..." : "Capture ECG Image")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isProcessing ? Color.gray : Color.green)
                .cornerRadius(15)
            }
            .disabled(isProcessing)
        }
    }
    
    private func toggleScanning() {
        isScanning.toggle()
        if isScanning {
            ecgService.startMonitoring()
        } else {
            ecgService.stopMonitoring()
        }
    }
    
    private func uploadImage(_ image: UIImage) {
        isProcessing = true
        
        Task {
            do {
                let result = await ecgService.uploadECGImage(image)
                await MainActor.run {
                    isProcessing = false
                    alertMessage = result
                    showAlert = true
                }
            }
        }
    }
    
    private func handleCameraButtonTap() {
        cameraService.checkCameraPermission()
        
        if cameraService.isAuthorized {
            showCamera = true
        } else if cameraService.canRequestPermission {
            // First time - show permission request
            cameraService.requestCameraPermission { granted in
                if granted {
                    self.showCamera = true
                }
            }
        } else {
            // Permission denied - show settings alert
            showPermissionAlert = true
        }
    }
}
