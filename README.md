# ElectroVector

**AI-Powered ECG Analysis & Vectorcardiography Conversion**

ElectroVector is an innovative iOS application that leverages machine learning to digitize electrocardiogram (ECG) scans and convert them into vectorcardiogram (VCG) diagrams. The app combines real-time ECG monitoring simulation with advanced image processing capabilities to provide comprehensive cardiac analysis.

## 🚀 Features

### 📱 Mobile App (iOS)
- **Real-time ECG Monitoring**: Simulated ECG waveform display with heart rate monitoring
- **Camera Integration**: Capture ECG images directly from physical ECG printouts
- **Image Upload**: Process captured ECG images for digitization
- **User-friendly Interface**: Intuitive SwiftUI-based design with beautiful animations
- **Permission Management**: Seamless camera permission handling

### 🤖 AI-Powered Backend
- **ECG Digitization**: Advanced machine learning models in the `MLbackend` folder convert ECG images to digital data
- **VCG Conversion**: Transform digitized ECG signals into vectorcardiogram representations
- **Server Processing**: Flask-based backend handles image processing and ML inference
- **Real-time Results**: Fast processing and response delivery

## 🏗 Architecture

```
ElectroVector/
├── iOS App (SwiftUI)
│   ├── ECGScannerView.swift      # Main interface
│   ├── ECGService.swift          # Network communication
│   ├── CameraView.swift          # Camera capture
│   ├── ECGWaveformView.swift     # Waveform visualization
│   └── Supporting Files
└── MLbackend/                    # Server-side ML models
    ├── Flask Server
    ├── ECG Digitization Models
    └── VCG Conversion Algorithms
```

## 📋 Requirements

### iOS App
- iOS 18.4+
- Xcode 16.3+
- Swift 5.0+
- Camera access permission

### Backend Server
- Python 3.8+
- Flask framework
- Machine learning dependencies (see MLbackend folder)
- ngrok for tunneling (development)

## 🛠 Setup & Installation

### 1. iOS App Setup
1. Clone the repository
2. Open `ElectroVector.xcodeproj` in Xcode
3. Update the development team in project settings
4. Build and run on device or simulator

### 2. Backend Server Setup
1. Navigate to the `MLbackend` folder
2. Install required Python dependencies
3. Start the Flask server
4. Update the server URL in `ECGService.swift` to point to your backend

### 3. Network Configuration
- For simulator testing: Use `127.0.0.1` or `localhost`
- For device testing: Use your computer's IP address or ngrok tunnel
- Update `serverURL` in `ECGService.swift` accordingly

## 📱 How to Use

1. **Launch the App**: Open ElectroVector on your iOS device
2. **Start Monitoring**: Tap "Start Monitoring" to begin real-time ECG simulation
3. **Capture ECG**: Use "Capture ECG Image" to photograph a physical ECG printout
4. **Processing**: The app uploads the image to the ML backend for analysis
5. **Results**: Receive digitized ECG data and VCG diagram conversion

## 🔧 Technical Details

### ECG Digitization Process
1. **Image Capture**: High-quality JPEG capture of ECG printouts
2. **Preprocessing**: Image enhancement and noise reduction
3. **Signal Extraction**: ML models identify and extract ECG waveforms
4. **Digitization**: Convert visual signals to numerical time-series data
5. **VCG Conversion**: Transform ECG leads into 3D vectorcardiogram

### API Communication
- **Endpoint**: `/digitize` (POST)
- **Format**: Multipart form data with image field
- **Response**: JSON with processing status and results
- **Error Handling**: Comprehensive error responses with detailed messages

## 🔒 Privacy & Security

- **Local Processing**: ECG simulation runs entirely on device
- **Secure Upload**: Images uploaded via HTTPS for ML processing
- **No Data Storage**: Images processed and discarded, no permanent storage
- **Permission-Based**: Camera access only when explicitly granted

## 🤝 Contributing

We welcome contributions! Please see the MLbackend folder for server-side improvements and submit pull requests for iOS app enhancements.

## 📄 License

[Add your license information here]

## 🙋‍♂️ Support

For technical support or questions about the ECG digitization algorithms, please refer to the documentation in the MLbackend folder or create an issue in this repository.

---

**ElectroVector** - Transforming cardiac care through AI-powered ECG analysis
