/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics
@testable import ImagineEngine

final class TextureImageLoaderMock: TextureImageLoader {
    private(set) var imageNames = Set<String>()
    var images = [String : CGImage]()

    func loadImageForTexture(named name: String, scale: Int, format: TextureFormat) -> CGImage? {
        let name = imageName(name, withScale: scale, format: format)
        imageNames.insert(name)
        return images[name]
    }

    func clearImageNames() {
        imageNames.removeAll()
    }

    private func imageName(_ name: String, withScale scale: Int, format: TextureFormat) -> String {
        var imageName = name

        if scale > 1 {
            imageName.append("@\(scale)x")
        }

        imageName.append(".\(format.rawValue)")

        return imageName
    }
}
