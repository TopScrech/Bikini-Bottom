import SwiftUI
import CoreVideo
import OSLog

@Observable
final class CoreVM {
    var output = ""
    
    func test(_ image: NSImage) {
        let marsHabitatPricer = try? Bikini_Bottom(configuration: .init())
        
        guard let pizels = pixelBuffer(from: image) else {
            output = "Error"
            return
        }
        
        do {
            let analyzeOutput = try marsHabitatPricer?.prediction(image: pizels)
            
            if let targetProbability = analyzeOutput?.targetProbability {
                print("Output:", targetProbability)
            } else {
                print("Output: nil")
            }
            
            guard let target = analyzeOutput?.target else {
                output = "Error"
                return
            }
            
            output = target
        } catch {
            Logger().error("\(error)")
            output = "Error"
        }
    }
    
    func pixelBuffer(from image: NSImage) -> CVPixelBuffer? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let frameSize = CGSize(width: cgImage.width, height: cgImage.height)
        var pixelBuffer: CVPixelBuffer?
        
        let attributes: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(frameSize.width),
            Int(frameSize.height),
            kCVPixelFormatType_32ARGB,
            attributes as CFDictionary,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(frameSize.width),
            height: Int(frameSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let ctx = context else {
            CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
            return nil
        }
        
        ctx.draw(cgImage, in: CGRect(origin: .zero, size: frameSize))
        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
        
        return buffer
    }
}
