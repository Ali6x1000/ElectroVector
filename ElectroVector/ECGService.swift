import SwiftUI
import Foundation

// MARK: - Response Structs
// Create structs to decode the JSON response from your server. This is much more reliable than parsing strings.
struct DigitizeResponse: Codable {
    let status: String
    let jobId: String
    let message: String
    let outputFiles: [String]
    let stdout: String?
}

struct ErrorResponse: Codable {
    let error: String
    let stderr: String?
}


@MainActor
class ECGService: ObservableObject {
    @Published var heartRate: Int = 72
    @Published var waveformData: [CGFloat] = []

    // ⭐️ FIX 1: Update the server URL to point to your local Flask server and the correct endpoint.
    // Remember to replace "127.0.0.1" with your computer's IP address if testing on a physical device.
    private var serverURL: String = "https://72065f8c4798.ngrok-free.app/digitize"

    private var timer: Timer?

    // The rest of your monitoring and waveform generation code remains the same...
    init() {
        generateInitialWaveform()
    }

    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.updateWaveform()
            self.updateHeartRate()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // ... (keep your private waveform generation functions here)
    private func generateInitialWaveform() { /* ... */ }
    private func updateWaveform() { /* ... */ }
    private func generateECGPoint(at x: Double) -> CGFloat { return 0.0 }
    private func updateHeartRate() { /* ... */ }
    
    // MARK: - Networking Function

    // ⭐️ FIX 2: Rewritten function for clarity, proper multipart creation, and JSON parsing.
    func digitizeECGImage(_ image: UIImage) async -> Result<DigitizeResponse, Error> {
        guard let url = URL(string: serverURL) else {
            return .failure(URLError(.badURL))
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .failure(NSError(domain: "ImageProcessingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG data."]))
        }
        
        // --- Multipart Form Data Creation ---
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the correct Content-Type for a multipart request
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Define the body of the request
        var body = Data()
        
        // ⭐️ FIX 3: Change the form field name from "ecg_image" to "image" to match the Flask server.
        let fieldName = "image"
        let filename = "ecg.jpg"
        
        // Append image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // (Optional) Add other form fields here if needed.
        // For example, to send the 'model_folder' parameter:
        // let modelFolder = "models/M3/"
        // body.append("--\(boundary)\r\n".data(using: .utf8)!)
        // body.append("Content-Disposition: form-data; name=\"model_folder\"\r\n\r\n".data(using: .utf8)!)
        // body.append(modelFolder.data(using: .utf8)!)
        // body.append("\r\n".data(using: .utf8)!)

        // Final boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body
        
        // --- Perform Network Request ---
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(URLError(.cannotParseResponse))
            }
            
            // ⭐️ FIX 4: Decode the JSON response based on the status code.
            if (200...299).contains(httpResponse.statusCode) {
                // Success
                let decodedResponse = try JSONDecoder().decode(DigitizeResponse.self, from: data)
                return .success(decodedResponse)
            } else {
                // Server-side error
                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                let error = NSError(domain: "ServerError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.error])
                return .failure(error)
            }
        } catch {
            return .failure(error)
        }
    }
}
