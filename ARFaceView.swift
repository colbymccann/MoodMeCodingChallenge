//
//  ARViewContainer.swift
//  MoodMeDemo
//
//  Created by Colby McCann on 12/13/24.
//

import SwiftUI
import RealityKit
import ARKit


struct ARFaceView : UIViewRepresentable {
    @ObservedObject var viewModel: ARFaceViewViewModel
    @Binding var isToggled: Bool
    let anchor = AnchorEntity(.face)
    
    func makeUIView(context: Context) -> ARView {
        viewModel.arView.automaticallyConfigureSession = false
        let config = ARFaceTrackingConfiguration()
        viewModel.arView.session.run(config)
        
        addEntity(isToggled: isToggled)
        
        viewModel.arView.scene.anchors.append(anchor)
        
        return viewModel.arView
    }
    
    func updateUIView(_ view: ARView, context: Context) {
        addEntity(isToggled: isToggled)
        viewModel.arView.session.pause()
        let config = ARFaceTrackingConfiguration()
        viewModel.arView.session.run(config)
        viewModel.arView.scene.anchors.append(anchor)
    }
    
    private func addEntity(isToggled: Bool) {
        anchor.children.removeAll()
        viewModel.arView.scene.anchors.removeAll()
        
        let entity: Entity
        if isToggled {
            entity = try! Entity.loadModel(named: "Mustache")
            entity.scale /= 14
            entity.position.y = -0.02
            entity.position.z = 0.06
        } else {
            entity = try! Entity.loadModel(named: "Beard_Goatee")
            entity.scale /= 8
            entity.position.y = -0.16
            entity.position.z = 0.12
            entity.orientation = simd_quatf(angle: -38.0 * (.pi / 180), axis: SIMD3(x: 1, y: 0, z: 0))
//            entity.orientation = simd_quatf(angle: .pi, axis: SIMD3(x: 0, y: 1, z: 0))
        }
        
        anchor.addChild(entity)
    }
}


extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA,
                                         attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        
        guard let cgImage = self.cgImage else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
}


