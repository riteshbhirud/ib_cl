//
//  BarcodeScannerView.swift
//  ib_clone
//
//  Created by rb on 1/22/26.
//

import SwiftUI
import AVFoundation
import Vision

struct BarcodeScannerView: View {
    let store: Store
    let onBarcodeScanned: (String, String, UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var isScanning = true
    @State private var scannedCode: String?
    @State private var scannedType: String?
    @State private var capturedImage: UIImage?
    @State private var showSuccess = false
    @State private var cameraPermissionDenied = false
    @State private var showSimulatorHelper = false
    
    // Check if running on simulator
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        ZStack {
            // Camera View or Simulator Fallback
            if isScanning {
                if isSimulator {
                    // Simulator fallback UI
                    simulatorFallbackView
                } else if cameraPermissionDenied {
                    // Permission denied UI
                    permissionDeniedView
                } else {
                    // Real camera view
                    BarcodeScannerCameraView(
                        isScanning: $isScanning,
                        onBarcodeDetected: { code, type, image in
                            handleBarcodeDetected(code: code, type: type, image: image)
                        },
                        onPermissionDenied: {
                            cameraPermissionDenied = true
                        }
                    )
                    .ignoresSafeArea()
                }
            }
            
            // Overlay UI
            VStack {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.appCallout(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.sm)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                }
                .padding(AppSpacing.lg)
                
                Spacer()
                
                // Scanning Frame
                VStack(spacing: AppSpacing.xl) {
                    // Scan Area
                    ZStack {
                        // Corner Brackets
                        ScannerFrameView()
                            .frame(width: 280, height: 160)
                        
                        // Scanning Animation
                        if isScanning {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.appPrimary.opacity(0), Color.appPrimary.opacity(0.3), Color.appPrimary.opacity(0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 280, height: 2)
                                .offset(y: scanLineOffset)
                        }
                    }
                    
                    // Instructions
                    VStack(spacing: AppSpacing.sm) {
                        Text(isScanning ? "Position barcode within frame" : "Barcode detected!")
                            .font(.appHeadline(.semibold))
                            .foregroundColor(.white)
                        
                        Text(isScanning ? "Make sure the barcode is clear and well-lit" : "Processing...")
                            .font(.appCallout(.regular))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.lg)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(16)
                }
                
                Spacer()
            }
            
            // Success Overlay
            if showSuccess, let code = scannedCode {
                successOverlay(code: code)
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Scan Line Animation
    @State private var scanLineOffset: CGFloat = -80
    
    private func startScanLineAnimation() {
        withAnimation(
            Animation.linear(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            scanLineOffset = 80
        }
    }
    
    // MARK: - Handle Barcode Detection
    private func handleBarcodeDetected(code: String, type: String, image: UIImage) {
        scannedCode = code
        scannedType = type
        capturedImage = image
        isScanning = false
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // Show success animation
        withAnimation(.spring(response: 0.5)) {
            showSuccess = true
        }
        
        // Auto continue after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let code = scannedCode, let type = scannedType, let image = capturedImage {
                onBarcodeScanned(code, type, image)
                dismiss()
            }
        }
    }
    
    // MARK: - Success Overlay
    private func successOverlay(code: String) -> some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xl) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(Color.appSuccess)
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(showSuccess ? 1 : 0.5)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccess)
                
                VStack(spacing: AppSpacing.sm) {
                    Text("Barcode Scanned!")
                        .font(.appTitle2(.bold))
                        .foregroundColor(.white)
                    
                    Text("Processing receipt...")
                        .font(.appCallout(.regular))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
    }
    
    // MARK: - On Appear
    private func onAppear() {
        startScanLineAnimation()
    }
    
    // MARK: - Simulator Fallback View
    private var simulatorFallbackView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xxxl) {
                Spacer()
                
                VStack(spacing: AppSpacing.xl) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.appPrimary)
                    }
                    
                    // Message
                    VStack(spacing: AppSpacing.sm) {
                        Text("Simulator Mode")
                            .font(.appTitle2(.bold))
                            .foregroundColor(.white)
                        
                        Text("Camera not available in simulator.\nUse a test barcode instead.")
                            .font(.appCallout(.regular))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                
                Spacer()
                
                // Test Barcode Button
                VStack(spacing: AppSpacing.md) {
                    Button(action: simulateBarcodeScan) {
                        HStack {
                            Image(systemName: "barcode")
                            Text("Use Test Barcode")
                                .font(.appHeadline(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.appPrimary)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                    }
                    .pressAnimation()
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.appCallout(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .pressAnimation()
                }
                .padding(AppSpacing.xl)
            }
        }
    }
    
    // MARK: - Permission Denied View
    private var permissionDeniedView: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: AppSpacing.xxxl) {
                Spacer()
                
                VStack(spacing: AppSpacing.xl) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.red.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "camera.fill.badge.ellipsis")
                            .font(.system(size: 56))
                            .foregroundColor(.red)
                    }
                    
                    // Message
                    VStack(spacing: AppSpacing.sm) {
                        Text("Camera Access Denied")
                            .font(.appTitle2(.bold))
                            .foregroundColor(.white)
                        
                        Text("Please enable camera access in Settings to scan receipt barcodes.")
                            .font(.appCallout(.regular))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.xl)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: AppSpacing.md) {
                    Button(action: openSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Open Settings")
                                .font(.appHeadline(.semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.appPrimary)
                        .cornerRadius(AppSpacing.buttonCornerRadius)
                    }
                    .pressAnimation()
                    
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.appCallout(.semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .pressAnimation()
                }
                .padding(AppSpacing.xl)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func simulateBarcodeScan() {
        // Create a test barcode with sample data
        let testBarcode = "TEST-RECEIPT-\(UUID().uuidString.prefix(8))"
        let testImage = createTestReceiptImage()
        
        handleBarcodeDetected(code: testBarcode, type: "Code128", image: testImage)
    }
    
    private func createTestReceiptImage() -> UIImage {
        let size = CGSize(width: 300, height: 400)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Store name
            let storeName = store.name.uppercased()
            let storeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let storeText = NSString(string: storeName)
            storeText.draw(at: CGPoint(x: 20, y: 20), withAttributes: storeAttributes)
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
            let dateString = dateFormatter.string(from: Date())
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            let dateText = NSString(string: dateString)
            dateText.draw(at: CGPoint(x: 20, y: 60), withAttributes: dateAttributes)
            
            // Barcode simulation
            let barcodeAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            let barcodeText = NSString(string: "|||||| || |||| | |||||")
            barcodeText.draw(at: CGPoint(x: 20, y: 350), withAttributes: barcodeAttributes)
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
        dismiss()
    }
}

// MARK: - Scanner Frame
struct ScannerFrameView: View {
    var body: some View {
        ZStack {
            // Corner Brackets
            ForEach(0..<4) { index in
                CornerBracket()
                    .stroke(Color.appPrimary, lineWidth: 4)
                    .frame(width: 30, height: 30)
                    .rotationEffect(.degrees(Double(index) * 90))
                    .offset(
                        x: index % 2 == 0 ? -125 : 125,
                        y: index < 2 ? -65 : 65
                    )
            }
        }
    }
}

struct CornerBracket: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

// MARK: - Camera View with Barcode Detection
struct BarcodeScannerCameraView: UIViewRepresentable {
    @Binding var isScanning: Bool
    let onBarcodeDetected: (String, String, UIImage) -> Void
    let onPermissionDenied: () -> Void
    
    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.onBarcodeDetected = onBarcodeDetected
        view.onPermissionDenied = onPermissionDenied
        view.isScanning = isScanning
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.isScanning = isScanning
    }
}

// MARK: - Camera Preview View
class CameraPreviewView: UIView {
    var onBarcodeDetected: ((String, String, UIImage) -> Void)?
    var onPermissionDenied: (() -> Void)?
    var isScanning = true
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let videoOutput = AVCaptureVideoDataOutput()
    private var lastScannedCode: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        checkCameraPermissionAndSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func checkCameraPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
                        self?.onPermissionDenied?()
                    }
                }
            }
            
        case .denied, .restricted:
            DispatchQueue.main.async { [weak self] in
                self?.onPermissionDenied?()
            }
            
        @unknown default:
            DispatchQueue.main.async { [weak self] in
                self?.onPermissionDenied?()
            }
        }
    }
    
    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ No camera device available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = bounds
            layer.addSublayer(previewLayer)
            
            self.captureSession = session
            self.previewLayer = previewLayer
            
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
            
            print("✅ Camera setup successful")
        } catch {
            print("❌ Camera setup error: \(error.localizedDescription)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
    
    deinit {
        captureSession?.stopRunning()
    }
}

// MARK: - Video Capture Delegate
extension CameraPreviewView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanning,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self = self,
                  let results = request.results as? [VNBarcodeObservation],
                  let barcode = results.first else {
                return
            }
            
            // Get the most accurate barcode data
            // For EAN13 and similar, descriptor has the complete data including check digit
            let barcodeData: String?
            if let descriptor = barcode.barcodeDescriptor as? CIBarcodeDescriptor {
                // Try to get raw data from descriptor first (most accurate)
                if let ean13Descriptor = descriptor as? CIQRCodeDescriptor {
                    // For QR codes, use payload
                    barcodeData = barcode.payloadStringValue
                } else {
                    // For linear barcodes (EAN13, Code128, etc), use payload
                    // but validate length for EAN13
                    if let payload = barcode.payloadStringValue {
                        if barcode.symbology == .ean13 {
                            // EAN13 must be exactly 13 digits
                            let digitsOnly = payload.filter { $0.isNumber }
                            if digitsOnly.count == 13 {
                                barcodeData = digitsOnly
                            } else if digitsOnly.count == 12 {
                                // If 12 digits, calculate check digit
                                barcodeData = digitsOnly + self.calculateEAN13CheckDigit(digitsOnly)
                            } else {
                                barcodeData = payload
                            }
                        } else {
                            barcodeData = payload
                        }
                    } else {
                        barcodeData = nil
                    }
                }
            } else {
                barcodeData = barcode.payloadStringValue
            }
            
            guard let finalBarcodeData = barcodeData,
                  self.lastScannedCode != finalBarcodeData else {
                return
            }
            
            self.lastScannedCode = finalBarcodeData
            
            // Capture image
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let image = UIImage(cgImage: cgImage)
            
            // Get barcode type
            let barcodeType = self.getBarcodeTypeName(barcode.symbology)
            
            // Log for debugging
            print("🔍 Scanned Barcode:")
            print("   Data: \(finalBarcodeData)")
            print("   Type: \(barcodeType)")
            print("   Length: \(finalBarcodeData.count)")
            
            DispatchQueue.main.async {
                self.onBarcodeDetected?(finalBarcodeData, barcodeType, image)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }
    
    // Calculate EAN13 check digit
    private func calculateEAN13CheckDigit(_ code: String) -> String {
        guard code.count == 12 else { return "" }
        
        var sum = 0
        for (index, char) in code.enumerated() {
            if let digit = Int(String(char)) {
                sum += (index % 2 == 0) ? digit : digit * 3
            }
        }
        
        let checkDigit = (10 - (sum % 10)) % 10
        return String(checkDigit)
    }
    
    private func getBarcodeTypeName(_ symbology: VNBarcodeSymbology) -> String {
        switch symbology {
        case .code128: return "Code128"
        case .pdf417: return "PDF417"
        case .qr: return "QR"
        case .aztec: return "Aztec"
        case .code39: return "Code39"
        case .code93: return "Code93"
        case .ean8: return "EAN8"
        case .ean13: return "EAN13"
        case .upce: return "UPCE"
        default: return "Unknown"
        }
    }
}

#Preview {
    BarcodeScannerView(
        store: Store(name: "Walmart", logoUrl: nil, description: nil),
        onBarcodeScanned: { _, _, _ in }
    )
}
