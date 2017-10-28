/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics
@testable import ImagineEngine

final class ImageMockFactory {
    static func makeImage(withSize size: Size) -> Image {
        return Image(cgImage: ImageMockFactory.makeCGImage(withSize: size))
    }

    static func makeCGImage(withSize size: Size) -> CGImage {
        let context = CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )!
        return context.makeImage()!
    }
}
