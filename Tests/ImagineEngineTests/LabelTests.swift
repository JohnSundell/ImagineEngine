/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

final class LabelTests: XCTestCase {
    private var label: Label!
    private var game: GameMock!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        label = Label()
        game = GameMock()
        game.scene.add(label)
    }

    // MARK: - Tests

    func testAutoResize() {
        // Verify initial size is zero
        XCTAssertEqual(label.size.width, 0)

        label.text = "Hello world"
        XCTAssertGreaterThan(label.size.width, 0)

        label.shouldAutoResize = false
        label.size = Size(width: 300, height: 300)
        label.text = "Hello again"
        XCTAssertEqual(label.size, Size(width: 300, height: 300))
    }

    func testLayerAndSceneReferenceRemovedWhenLabelIsRemoved() {
        XCTAssertNotNil(label.layer.superlayer)
        XCTAssertNotNil(label.scene)

        label.remove()
        XCTAssertNil(label.layer.superlayer)
        XCTAssertNil(label.scene)
    }

    func testSettingHorizontalAlignment() {
        // Make sure that "left" is the default
        XCTAssertEqual(label.layer.alignmentMode, kCAAlignmentLeft)

        label.horizontalAlignment = .right
        XCTAssertEqual(label.layer.alignmentMode, kCAAlignmentRight)
    }
}
