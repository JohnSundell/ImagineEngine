/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

class CGImageLoadTests: XCTestCase {
    private var bundle: Bundle!

    override func setUp() {
        bundle = Bundle(for: type(of: self))
    }

    func testLoadsPNGImage() {
        let url = bundle.url(forResource: "sample", withExtension: "png")!

        let image = CGImage.load(withContentsOf: url, format: .png)
        XCTAssertNotNil(image)
    }

    func testLoadsJPGImage() {
        let url = bundle.url(forResource: "sample", withExtension: "jpg")!

        let image = CGImage.load(withContentsOf: url, format: .jpg)
        XCTAssertNotNil(image)
    }
}
