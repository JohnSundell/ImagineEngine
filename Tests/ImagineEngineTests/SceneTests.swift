/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
import ImagineEngine

final class SceneTests: XCTestCase {
    private var game: GameMock!

    override func setUp() {
        super.setUp()
        game = GameMock()
    }

    func testAddingAndRemovingActor() {
        let actor = Actor()

        game.scene.add(actor)
        XCTAssertEqual(game.scene.actors, [actor])
        assertSameInstance(game.scene, actor.scene)

        actor.remove()
        XCTAssertEqual(game.scene.actors, [])
        XCTAssertNil(actor.scene)
    }

    func testAddingAndRemovingBlock() {
        let block = Block(size: .zero, textureCollectionName: "Block")

        game.scene.add(block)
        XCTAssertEqual(game.scene.blocks, [block])
        assertSameInstance(game.scene, block.scene)

        block.remove()
        XCTAssertEqual(game.scene.blocks, [])
        XCTAssertNil(block.scene)
    }

    func testAddingAndRemovingLabel() {
        let label = Label()

        game.scene.add(label)
        XCTAssertEqual(game.scene.labels, [label])
        assertSameInstance(game.scene, label.scene)

        label.remove()
        XCTAssertEqual(game.scene.labels, [])
        XCTAssertNil(label.scene)
    }

    func testAddingAndRemovingPlugin() {
        let plugin = PluginMock<Scene>()

        game.scene.add(plugin)
        XCTAssertTrue(plugin.isActive)
        assertSameInstance(plugin.object, game.scene)
        assertSameInstance(plugin.game, game)

        game.scene.remove(plugin)
        XCTAssertFalse(plugin.isActive)
    }

    func testPluginActivationAndDeactivation() {
        let scene = Scene(size: Size(width: 300, height: 300))

        let plugin = PluginMock<Scene>()
        scene.add(plugin)
        XCTAssertFalse(plugin.isActive)

        // Plugin shouldn't be activated until the scene is
        game.scene = scene
        XCTAssertTrue(plugin.isActive)

        // When scene is removed, plugin should be deactivated
        game.scene = Scene(size: Size(width: 300, height: 300))
        XCTAssertFalse(plugin.isActive)
    }

    func testSamePluginAddedMultipleTimesReturnsSameInstance() {
        let scene = Scene(size: Size(width: 300, height: 300))

        let plugin = PluginMock<Scene>()
        assertSameInstance(plugin, scene.add(plugin))

        // The 2nd instance shouldn't be used, since the scen already has
        // an existing plugin instance attached of the same type
        let anotherPlugin = PluginMock<Scene>()
        assertSameInstance(plugin, scene.add(anotherPlugin))
    }

    func testReset() {
        let actor = Actor()
        let block = Block(size: .zero, textureCollectionName: "Block")
        let label = Label()
        let plugin = PluginMock<Scene>()

        game.scene.add(actor)
        game.scene.add(block)
        game.scene.add(label)
        game.scene.add(plugin)
        game.scene.size = Size(width: 500, height: 500)
        game.scene.camera.position = Point(x: 700, y: 900)

        game.scene.reset()
        XCTAssertTrue(game.scene.actors.isEmpty)
        XCTAssertTrue(game.scene.blocks.isEmpty)
        XCTAssertTrue(game.scene.labels.isEmpty)

        // Plugins should not be removed as part of a reset
        XCTAssertTrue(plugin.isActive)

        // Camera should be back at the starting point
        XCTAssertEqual(game.scene.camera.position, Point(x: 250, y: 250))
    }

    func testPausing() {
        let actor = Actor()
        actor.move(to: Point(x: 100, y: 100), duration: 5)
        game.scene.add(actor)
        game.update()

        game.timeTraveler.travel(by: 1)
        game.update()
        XCTAssertEqual(actor.position, Point(x: 20, y: 20))

        // No local time should elapse while paused
        game.scene.isPaused = true
        game.timeTraveler.travel(by: 4)
        game.update()
        XCTAssertEqual(actor.position, Point(x: 20, y: 20))

        // When unpausing, the game should resume from where it was
        game.scene.isPaused = false
        game.update()
        XCTAssertEqual(actor.position, Point(x: 20, y: 20))

        // Local time should be offset by the pause interval from now on
        game.timeTraveler.travel(by: 3)
        game.update()
        XCTAssertEqual(actor.position, Point(x: 80, y: 80))
    }

    func testClickPointAdjustedForCamera() {
        var clickedPoint: Point?

        game.scene.events.clicked.observe { _, point in
            clickedPoint = point
        }

        // When the scene & the camera are of the same size, no adjustments are needed
        game.view.frame.size = Size(width: 300, height: 600)
        game.scene.size = game.view.frame.size
        game.scene.camera.position = game.scene.center
        game.simulateClick(at: Point(x: 150, y: 300))
        XCTAssertEqual(clickedPoint, Point(x: 150, y: 300))

        // When camera in the upper-left corner, no adjustments are needed either
        game.scene.size = Size(width: 3000, height: 6000)
        game.scene.camera.position = Point(x: 150, y: 300)
        game.simulateClick(at: Point(x: 150, y: 300))
        XCTAssertEqual(clickedPoint, Point(x: 150, y: 300))

        // When camera is moved, the click point should be adjusted accordingly
        game.scene.camera.position = Point(x: 1000, y: 1500)
        game.simulateClick(at: Point(x: 200, y: 350))
        XCTAssertEqual(clickedPoint, Point(x: 1050, y: 1550))
    }
}
