import AVFoundation
import SwiftUI
import RealityKit
import ARKit
import UniformTypeIdentifiers

class ARFaceViewViewModel: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ARSessionDelegate, ObservableObject {
    let arView = ARView(frame: .zero)
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureVideoDataOutput?
    var isRecording = false
    var videoWriter: AVAssetWriter?
    var videoInput: AVAssetWriterInput?
    var videoWriterAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var startTime: CMTime?
    
    
    @Published var showAlert: Bool = false
    @Published var videoURL: URL = URL(fileURLWithPath: NSTemporaryDirectory() + "default.mov")
    @Published var videoDuration: Double = 0.0
    @Published var firstFrameURL: URL = URL(fileURLWithPath: "")
    

    func startRecording() {
        guard !isRecording else { return }
        isRecording = true

        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            videoURL = documentsDirectory.appendingPathComponent(UUID().uuidString + ".mov")
        }
        
        do {
            videoWriter = try AVAssetWriter(outputURL: videoURL, fileType: .mov)
            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: 1280,
                AVVideoHeightKey: 720,

            ]
            videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            videoInput?.transform = CGAffineTransform(rotationAngle: (.pi / 2))
            videoWriter?.add(videoInput!)
            
            
            videoWriterAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput!)

            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: .zero)

            arView.session.delegate = self

        } catch {
            print("Failed to set up video writer: \(error)")
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        isRecording = false

        arView.session.delegate = nil
        
        videoInput?.markAsFinished()
        videoWriter?.finishWriting {
            if let error = self.videoWriter?.error {
                print("Error while finishing video writing: \(error)")
            }
            DispatchQueue.main.async {
                self.resetRecordingState()
                self.showAlert = true
                self.extractVideoDetails()
            }
        }
    }
    
    private func resetRecordingState() {
        videoWriter = nil
        videoInput = nil
        videoWriterAdaptor = nil

        startTime = nil

        print("Recording state has been reset")
    }
    
    func extractVideoDetails() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: videoURL, includingPropertiesForKeys: nil, options: [])
            print(files)
        } catch {
            
        }
        
        
        let asset = AVURLAsset(url: videoURL)

        videoDuration = CMTimeGetSeconds(asset.duration)
        print(videoDuration)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true // Corrects orientation

        do {
            let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            let frameURL = saveImageAsFile(cgImage)
            DispatchQueue.main.async {
                self.firstFrameURL = frameURL ?? URL(fileURLWithPath: "")
            }
        } catch {
            print("Failed to generate first frame: \(error)")
        }
    }
            
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard isRecording else { return }

        let currentTime = CMTime(seconds: frame.timestamp, preferredTimescale: 600)

        if startTime == nil {
            startTime = currentTime
            guard videoWriter?.status == .unknown else {
                print("Video writer status is not unknown: \(videoWriter?.status.rawValue ?? -1)")
                return
            }
            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: currentTime)
        }

        guard let startTime = startTime else { return }
        let presentationTime = CMTimeSubtract(currentTime, startTime)

        let pixelBuffer = frame.capturedImage
        if videoWriterAdaptor?.assetWriterInput.isReadyForMoreMediaData == true {
            videoWriterAdaptor?.append(pixelBuffer, withPresentationTime: presentationTime)
        }

    }
    
    private func saveImageAsFile(_ cgImage: CGImage) -> URL? {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + ".png")
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, UTType.png.identifier as CFString, 1, nil) else {
                print("Failed to create image destination")
                return nil
        }
        CGImageDestinationAddImage(destination, cgImage, nil)
        if CGImageDestinationFinalize(destination) {
            return fileURL
        } else {
            print("Failed to save image to file")
            return nil
        }
    }
    
    func cancelVideo() {
        try? FileManager.default.removeItem(at: videoURL)
        print("Video file deleted")
    }
}

