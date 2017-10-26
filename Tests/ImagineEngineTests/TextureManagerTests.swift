/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

class TextureManagerTests: XCTestCase {
    func testFallsBackToLowerScaleTextures() {
        let imageLoader = TextureImageLoaderMock()
        let manager = TextureManager()
        manager.imageLoader = imageLoader

        _ = manager.load(Texture(name: "texture"), namePrefix: nil, scale: 3)

        XCTAssert(imageLoader.imageNames.contains("texture@3x"))
        XCTAssert(imageLoader.imageNames.contains("texture@2x"))
        XCTAssert(imageLoader.imageNames.contains("texture"))
    }
}
