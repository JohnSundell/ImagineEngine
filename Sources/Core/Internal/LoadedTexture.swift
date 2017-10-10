/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics

internal final class LoadedTexture {
    let image: CGImage
    let scale: Int

    init(image: CGImage, scale: Int) {
        self.image = image
        self.scale = scale
    }
}

extension LoadedTexture {
    var size: Size {
        return Size(width: image.width / scale, height: image.height / scale)
    }

    convenience init?(image: Image) {
        guard let cgImage = image.cgImage else {
            return nil
        }

        self.init(image: cgImage, scale: Int(image.scale))
    }
}
