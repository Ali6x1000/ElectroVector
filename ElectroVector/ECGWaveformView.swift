import SwiftUI

struct ECGWaveformView: View {
    let isActive: Bool
    @ObservedObject var ecgService: ECGService
    @State private var phase: CGFloat = 0
    
    var body: some View {
        Canvas { context, size in
            let path = createECGPath(in: size)
            
            // Background grid
            drawGrid(context: context, size: size)
            
            // ECG waveform
            context.stroke(
                path,
                with: .color(.green),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
            
            // Scanning line
            if isActive {
                let scanLineX = (phase.truncatingRemainder(dividingBy: 1)) * size.width
                let scanLine = Path { path in
                    path.move(to: CGPoint(x: scanLineX, y: 0))
                    path.addLine(to: CGPoint(x: scanLineX, y: size.height))
                }
                context.stroke(scanLine, with: .color(.yellow), lineWidth: 1)
            }
        }
        .onAppear {
            if isActive {
                startAnimation()
            }
        }
        .onChange(of: isActive) { _, newValue in
            if newValue {
                startAnimation()
            }
        }
    }
    
    private func createECGPath(in size: CGSize) -> Path {
        Path { path in
            let points = ecgService.waveformData
            guard !points.isEmpty else { return }
            
            let stepX = size.width / CGFloat(points.count - 1)
            let centerY = size.height / 2
            let amplitude = size.height * 0.4
            
            path.move(to: CGPoint(x: 0, y: centerY + points[0] * amplitude))
            
            for (index, point) in points.enumerated() {
                let x = CGFloat(index) * stepX
                let y = centerY + point * amplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
    }
    
    private func drawGrid(context: GraphicsContext, size: CGSize) {
        let gridSpacing: CGFloat = 20
        let gridPath = Path { path in
            // Vertical lines
            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += gridSpacing
            }
            
            // Horizontal lines
            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += gridSpacing
            }
        }
        
        context.stroke(gridPath, with: .color(.green.opacity(0.2)), lineWidth: 0.5)
    }
    
    private func startAnimation() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            phase += 1
        }
    }
}
