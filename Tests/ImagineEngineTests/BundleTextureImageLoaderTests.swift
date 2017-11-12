/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

class BundleTextureImageLoaderTests: XCTestCase {
    func testLoadsImageWithSpecifiedFormat() {
        let bundle = BundleMock()
        let loader = BundleTextureImageLoader(bundle: bundle)
        _ = loader.loadImageForTexture(named: "texture", scale: 1, format: .png)
        _ = loader.loadImageForTexture(named: "ground", scale: 2, format: .jpg)

        XCTAssertEqual(bundle.resourceNames, ["texture.png", "ground@2x.jpg"])
    }

    func testLoadsPNGImage() {
        let loader = BundleTextureImageLoader(bundle: Bundle(for: type(of: self)))
        let loadedImage = loader.loadImageForTexture(named: "sample", scale: 1, format: .png)!

        XCTAssertNotNil(loadedImage)
    }

    func testLoadsJPGImage() {
        let loader = BundleTextureImageLoader(bundle: Bundle(for: type(of: self)))
        let loadedImage = loader.loadImageForTexture(named: "sample", scale: 1, format: .jpg)!

        XCTAssertNotNil(loadedImage)
    }
}
