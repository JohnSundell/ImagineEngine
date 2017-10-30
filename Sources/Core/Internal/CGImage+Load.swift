/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics

internal extension CGImage {
    static func load(withContentsOf url: URL, format: TextureFormat) -> CGImage? {
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
        case .unknown:
            assertionFailure("Tried to load texture of an unknown format. Must not be reached.")
            return nil
        }
    }
}
