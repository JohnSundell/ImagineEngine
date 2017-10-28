/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

class TextureManagerTests: XCTestCase {
    private var manager: TextureManager!
    private var imageLoader: TextureImageLoaderMock!

    override func setUp() {
        manager = TextureManager()
        imageLoader = TextureImageLoaderMock()
        manager.imageLoader = imageLoader
    }

    func testFallsBackToLowerScaleTextures() {
        _ = manager.load(Texture(name: "texture"), namePrefix: nil, scale: 3)

        XCTAssertEqual(imageLoader.imageNames, ["texture@3x", "texture@2x", "texture"])
    }

    func testRemembersTextureScaleFallback() {
        imageLoader.images["texture@2x"] = makeImage()

        _ = manager.load(Texture(name: "texture"), namePrefix: nil, scale: 3)
        XCTAssertEqual(imageLoader.imageNames, ["texture@3x", "texture@2x"])

        imageLoader.clearImageNames()

        _ = manager.load(Texture(name: "texture"), namePrefix: nil, scale: 3)
        XCTAssert(imageLoader.imageNames.isEmpty)
    }

    private func makeImage() -> CGImage {
        return ImageMockFactory.makeCGImage(withSize: Size(width: 1, height: 1))
    }
}
