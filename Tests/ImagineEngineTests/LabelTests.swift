/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
import ImagineEngine

final class LabelTests: XCTestCase {
    func testAutoResize() {
        let label = Label()
        XCTAssertEqual(label.size.width, 0)

        label.text = "Hello world"
        XCTAssertGreaterThan(label.size.width, 0)

        label.shouldAutoResize = false
        label.size = Size(width: 300, height: 300)
        label.text = "Hello again"
        XCTAssertEqual(label.size, Size(width: 300, height: 300))
    }
}
