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

    func loadImageForTexture(named name: String) -> CGImage? {
        imageNames.insert(name)
        return images[name]
    }
}
