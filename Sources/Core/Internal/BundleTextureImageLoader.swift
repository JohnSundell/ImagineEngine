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

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            return nil
        }

        switch format {
        case .png:
            return CGImage(pngDataProviderSource: dataProvider,
                           decode: nil,
                           shouldInterpolate: false,
                           intent: .defaultIntent)
        case .jpg:
            return CGImage(jpegDataProviderSource: dataProvider,
                           decode: nil,
                           shouldInterpolate: false,
                           intent: .defaultIntent)
        }
    }
}
