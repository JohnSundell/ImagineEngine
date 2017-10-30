/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

class BundleTextureImageLoaderTests: XCTestCase {
    private var bundle: BundleMock!
    private var loader: BundleTextureImageLoader!

    override func setUp() {
        bundle = BundleMock()
        loader = BundleTextureImageLoader(bundle: bundle)
    }

    func testLoadsImageWithSpecifiedFormat() {
        _ = loader.loadImageForTexture(named: "texture", scale: 1, format: .png)
        _ = loader.loadImageForTexture(named: "ground", scale: 2, format: .jpg)

        XCTAssertEqual(bundle.resourceNames, ["texture.png", "ground@2x.jpg"])
    }

    func testDoesNotLoadImageWithUnknownFormat() {
        _ = loader.loadImageForTexture(named: "texture", scale: 1, format: .unknown)

        XCTAssert(bundle.resourceNames.isEmpty)
    }
}
