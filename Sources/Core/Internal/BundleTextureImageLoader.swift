/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics

internal final class BundleTextureImageLoader: TextureImageLoader {
    private let bundle: BundleProtocol

    init(bundle: BundleProtocol = Bundle.main) {
        self.bundle = bundle
    }

    func loadImageForTexture(named name: String, scale: Int, format: TextureFormat) -> CGImage? {
        var imageName = name

        if scale > 1 {
            imageName.append("@\(scale)x")
        }

        guard let url = bundle.url(forResource: imageName, withExtension: format.rawValue) else {
            return nil
        }

        return CGImage.load(withContentsOf: url, format: format)
    }
}
