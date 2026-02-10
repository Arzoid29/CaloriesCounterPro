import UIKit
import ImageIO

extension UIImage {

    /// Downsample an image to reduce memory usage before processing.
    /// Uses ImageIO for efficient memory handling (no full decode of original).
    func downsampled(maxDimension: CGFloat = 2048) -> UIImage {
        guard let data = self.jpegData(compressionQuality: 0.8) else { return self }
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache: false
        ]
        guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else {
            return self
        }

        let downsampleOptions: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension
        ]

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else {
            return self
        }

        return UIImage(cgImage: downsampledImage)
    }
}
