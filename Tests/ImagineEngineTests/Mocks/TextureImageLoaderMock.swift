/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreGraphics
import ImagineEngine

final class TextureImageLoaderMock: TextureImageLoader {
    private(set) var imageNames = Set<String>()
    var images = [String : CGImage]()

    func loadImageForTexture(named name: String, scale: Int) -> CGImage? {
        let name = imageName(name, withScale: scale)
        imageNames.insert(name)
        return images[name]
    }

    func clearImageNames() {
        imageNames.removeAll()
    }

    private func imageName(_ name: String, withScale scale: Int) -> String {
        guard scale > 1 else {
            return name
        }

        return "\(name)@\(scale)x"
    }
}
