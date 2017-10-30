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
        _ = manager.load(Texture(name: "texture", format: .unknown), namePrefix: nil, scale: 3)

        XCTAssertEqual(imageLoader.imageNames, ["texture@3x", "texture@2x", "texture"])
    }

    func testRemembersTextureScaleFallback() {
        let textureToLoad = Texture(name: "texture", format: .unknown)
        imageLoader.images["texture@2x"] = makeImage()

        _ = manager.load(textureToLoad, namePrefix: nil, scale: 3)
        XCTAssertEqual(imageLoader.imageNames, ["texture@3x", "texture@2x"])

        imageLoader.clearImageNames()

        _ = manager.load(textureToLoad, namePrefix: nil, scale: 3)
        XCTAssert(imageLoader.imageNames.isEmpty)
    }

    func testUsesCorrectFormatWhenLoadingTexture() {
        let pngTexture = Texture(name: "texture", format: .png)
        let jpgTexture = Texture(name: "texture", format: .jpg)
        let pngImage = makeImage()
        let jpgImage = makeImage()
        imageLoader.images["texture.png"] = pngImage
        imageLoader.images["texture.jpg"] = jpgImage

        let loadedPNGTexture = manager.load(pngTexture, namePrefix: nil, scale: 1)!
        let loadedJPGTexture = manager.load(jpgTexture, namePrefix: nil, scale: 1)!

        XCTAssert(loadedPNGTexture.image === pngImage)
        XCTAssert(loadedJPGTexture.image === jpgImage)
    }

    private func makeImage() -> CGImage {
        return ImageMockFactory.makeCGImage(withSize: Size(width: 1, height: 1))
    }
}
