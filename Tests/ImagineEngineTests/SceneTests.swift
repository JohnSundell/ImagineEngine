/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

final class SceneTests: XCTestCase {
    private var game: GameMock!

    override func setUp() {
        super.setUp()
        game = GameMock()
    }

    func testAddingAndRemovingActor() {
        var addedActor: Actor?
        var removedActor: Actor?

        game.scene.events.actorAdded.observe { _, actor in
            addedActor = actor
        }

        game.scene.events.actorRemoved.observe { _, actor in
            removedActor = actor
        }

        let actor = Actor()

        game.scene.add(actor)
        XCTAssertEqual(game.scene.actors, [actor])
        assertSameInstance(game.scene, actor.scene)
        assertSameInstance(addedActor, actor)

        actor.remove()
        XCTAssertEqual(game.scene.actors, [])
        XCTAssertNil(actor.scene)
        assertSameInstance(removedActor, actor)
    }

    func testAddingAndRemovingMultipleActors() {
        let actor1 = Actor()
        let actor2 = Actor()

        game.scene.add(actor1, actor2)

        let actors: Set<Actor> = [actor1, actor2]
        XCTAssertEqual(game.scene.actors, actors)

        for actor in actors {
            assertSameInstance(game.scene, actor.scene)
            actor.remove()
            XCTAssertNil(actor.scene)
        }

        XCTAssertEqual(game.scene.actors, [])
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

    func testAddingAndRemovingMultipleBlocks() {
        let block1 = Block(size: .zero, textureCollectionName: "Block1")
        let block2 = Block(size: .zero, textureCollectionName: "Block2")

        game.scene.add(block1, block2)

        let blocks: Set<Block> = [block1, block2]
        XCTAssertEqual(game.scene.blocks, blocks)

        for block in blocks {
            assertSameInstance(game.scene, block.scene)
            block.remove()
            XCTAssertNil(block.scene)
        }

        XCTAssertEqual(game.scene.blocks, [])
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

    func testAddingAndRemovingMultipleLabels() {
        let label1 = Label()
        let label2 = Label()

        game.scene.add(label1, label2)

        let labels:Set<Label> = [label1, label2]
        XCTAssertEqual(game.scene.labels, labels)

        for label in labels {
            assertSameInstance(game.scene, label.scene)
            label.remove()
            XCTAssertNil(label.scene)
        }

        XCTAssertEqual(game.scene.labels, [])
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

    func testReusingSamePluginInstance() {
        let scene = Scene(size: Size(width: 300, height: 300))

        let plugin = PluginMock<Scene>()
        assertSameInstance(plugin, scene.add(plugin))

        // The 2nd instance shouldn't be used, since the scen already has
        // an existing plugin instance attached of the same type
        let anotherPlugin = PluginMock<Scene>()
        assertSameInstance(plugin, scene.add(anotherPlugin))
    }

    func testRemovingAllPluginsOfType() {
        var pluginA: PluginMock! = PluginMock<Scene>()
        var pluginB: PluginMock! = PluginMock<Scene>()

        game.scene.add(pluginA)
        game.scene.add(pluginB, reuseExistingOfSameType: false)
        XCTAssertTrue(pluginA.isActive)
        XCTAssertTrue(pluginB.isActive)

        game.scene.removePlugins(ofType: PluginMock.self)
        XCTAssertFalse(pluginA.isActive)
        XCTAssertFalse(pluginB.isActive)

        // Make sure the scene is not still retaining the plugins after removing them
        weak var weakPluginA = pluginA
        weak var weakPluginB = pluginB
        pluginA = nil
        pluginB = nil
        XCTAssertNil(weakPluginA)
        XCTAssertNil(weakPluginB)
    }

    func testDisablingPluginReuse() {
        let scene = Scene(size: Size(width: 300, height: 300))

        let plugin = PluginMock<Scene>()
        assertSameInstance(plugin, scene.add(plugin))

        let anotherPlugin = PluginMock<Scene>()
        assertSameInstance(anotherPlugin, scene.add(anotherPlugin, reuseExistingOfSameType: false))

        // Both plugins should now be activated...
        game.scene = scene
        XCTAssertTrue(plugin.isActive)
        XCTAssertTrue(anotherPlugin.isActive)

        // ...and deactivated
        game.scene = Scene(size: Size(width: 300, height: 300))
        XCTAssertFalse(plugin.isActive)
        XCTAssertFalse(anotherPlugin.isActive)
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

        // All objects should have their scene reference removed
        XCTAssertNil(actor.scene)
        XCTAssertNil(block.scene)
        XCTAssertNil(label.scene)

        // Plugins should not be removed as part of a reset, but they
        // should have been deactivated and then activated again
        XCTAssertEqual(plugin.deactivationCount, 1)
        XCTAssertEqual(plugin.activationCount, 2)
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

    func testClickPluginAlwaysAdded() {
        let scene = Scene(size: .zero)
        let plugins = scene.plugins(ofType: ClickPlugin.self)
        XCTAssertFalse(plugins.isEmpty)
    }

    func testSafeAreaInsets() {
        // Verify default
        XCTAssertEqual(game.scene.safeAreaInsets, EdgeInsets())

        // This test is only relevant for iOS, since macOS has no concept of safe area insets
        #if !os(macOS)
        guard #available(iOS 11, tvOS 11, *) else {
            return
        }

        var observationTriggerCount = 0

        game.scene.events.safeAreaInsetsChanged.observe {
            observationTriggerCount += 1
        }

        game.mockedView.mockedSafeAreaInsets = EdgeInsets(top: 10, left: 30, bottom: 20, right: 15)
        game.mockedView.safeAreaInsetsDidChange()
        XCTAssertEqual(game.scene.safeAreaInsets, EdgeInsets(top: 10, left: 30, bottom: 20, right: 15))
        XCTAssertEqual(observationTriggerCount, 1)

        // When the same safe area insets get assigned, no observation should be triggered
        game.mockedView.safeAreaInsetsDidChange()
        XCTAssertEqual(observationTriggerCount, 1)
        #endif
    }

    func testActorsAtPoint() {
        let actorA = Actor(size: Size(width: 100, height: 100))
        let actorB = Actor(size: Size(width: 100, height: 100))
        game.scene.add(actorA, actorB)

        // Since both actors are at (0, 0), they should both be returned
        // Actor B should be returned first, since it's on the top
        XCTAssertEqual(game.scene.actors(at: .zero), [actorB, actorA])

        // Move actor A slightly away, but still within the same grid tile
        // to make sure it isn't invalidly returned
        actorA.position.x = 60
        XCTAssertEqual(game.scene.actors(at: .zero), [actorB])
    }

    func testLabelsAtPoint() {
        let labelA = Label(text: "Hello")
        let labelB = Label(text: "World")
        game.scene.add(labelA, labelB)

        // Since both labels are at (0, 0), they should both be returned
        // Label B should be returned first, since it's on the top
        XCTAssertEqual(game.scene.labels(at: .zero), [labelB, labelA])

        // Move label A slightly away, but still within the same grid tile
        // to make sure it isn't invalidly returned
        labelA.position.x += labelA.size.width / 2 + 10
        XCTAssertEqual(game.scene.labels(at: .zero), [labelB])
    }

    func testObservingResize() {
        var sizes = [Size]()

        game.scene.events.resized.observe { scene in
            sizes.append(scene.size)
        }

        game.scene.size = Size(width: 1000, height: 200)
        XCTAssertEqual(sizes, [Size(width: 1000, height: 200)])

        game.scene.size = .zero
        XCTAssertEqual(sizes, [Size(width: 1000, height: 200), .zero])

        // Setting the same size again should not retrigger the event
        game.scene.size = .zero
        XCTAssertEqual(sizes, [Size(width: 1000, height: 200), .zero])
    }
}
