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
    func testWrapped() {
        // Check its default value (false)
        XCTAssertEqual(label.layer.isWrapped, false)

        label.shouldWrap = true
        XCTAssertEqual(label.shouldWrap, label.layer.isWrapped)
    }

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

    func testAddingAndRemovingPlugin() {
        let plugin = PluginMock<Label>()

        label.add(plugin)
        XCTAssertTrue(plugin.isActive)
        assertSameInstance(plugin.object, label)
        assertSameInstance(plugin.game, game)

        label.remove(plugin)
        XCTAssertFalse(plugin.isActive)
    }

    func testPluginActivationAndDeactivation() {
        let label = Label()

        let plugin = PluginMock<Label>()
        label.add(plugin)
        XCTAssertFalse(plugin.isActive)

        // Plugin shouldn't be activated until the label is added
        game.scene.add(label)
        XCTAssertTrue(plugin.isActive)

        // When label is removed, plugin should be deactivated
        label.remove()
        XCTAssertFalse(plugin.isActive)
    }

    func testObservingClicks() {
        let labelA = Label(text: "Hello")
        let labelB = Label(text: "World")
        game.scene.add(labelA, labelB)

        var labelAClickCount = 0
        var labelBClickCount = 0
        var clickedLabels = [Label]()

        labelA.events.clicked.observe { label in
            labelAClickCount += 1
            clickedLabels.append(label)
        }

        labelB.events.clicked.observe { label in
            labelBClickCount += 1
            clickedLabels.append(label)
        }

        game.simulateClick(at: .zero)

        XCTAssertEqual(labelAClickCount, 1)
        XCTAssertEqual(labelBClickCount, 1)
        XCTAssertEqual(clickedLabels, [labelB, labelA])

        // Move label to make sure that the grid is updated
        labelA.position = Point(x: 200, y: 300)
        game.simulateClick(at: Point(x: 200, y: 300))

        // Only labelA should have been clicked twice
        XCTAssertEqual(labelAClickCount, 2)
        XCTAssertEqual(labelBClickCount, 1)
        XCTAssertEqual(clickedLabels, [labelB, labelA, labelA])
    }
    
    func testObservingRotate() {
        let label = Label(text: "Greetings")
        
        var labelRotateCount = 0
        label.events.rotated.observe {
            labelRotateCount += 1
        }
        
        XCTAssertEqual(labelRotateCount, 0)
        XCTAssertEqual(label.rotation, 0)
        label.rotation = 90
        XCTAssertEqual(label.rotation, 90)
        label.rotation = -90
        XCTAssertEqual(label.rotation, -90)
        XCTAssertEqual(labelRotateCount, 2)
    }
}
