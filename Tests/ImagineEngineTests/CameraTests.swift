/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
import ImagineEngine

final class CameraTests: XCTestCase {
    private var game: GameMock!

    override func setUp() {
        super.setUp()
        game = GameMock()
    }

    func testInitialPositionIsCenterOfScene() {
        let scene = Scene(size: Size(width: 500, height: 500))
        XCTAssertEqual(scene.camera.position, Point(x: 250, y: 250))
    }

    func testSizeSetWhenSceneIsActivated() {
        game.view.frame.size = Size(width: 100, height: 100)

        let scene = Scene(size: Size(width: 500, height: 500))
        XCTAssertEqual(scene.camera.size, .zero)

        game.scene = scene
        XCTAssertEqual(scene.camera.size, Size(width: 100, height: 100))
    }

    func testRect() {
        // Initially the camera should have a zero size rect at the scene's center point
        let scene = Scene(size: Size(width: 500, height: 300))
        XCTAssertEqual(scene.camera.rect, Rect(x: 250, y: 150, width: 0, height: 0))

        // When the scene is added to a game the rect should be the full view port
        game.view.frame.size = Size(width: 100, height: 200)
        game.scene = scene
        XCTAssertEqual(scene.camera.rect, Rect(x: 200, y: 50, width: 100, height: 200))

        // When the camera is moved, the rect should be updated
        scene.camera.position = Point(x: 50, y: 100)
        XCTAssertEqual(scene.camera.rect, Rect(x: 0, y: 0, width: 100, height: 200))
    }

    func testAddingAndRemovingPlugin() {
        let plugin = PluginMock<Camera>()

        game.scene.camera.add(plugin)
        XCTAssertTrue(plugin.isActive)
        assertSameInstance(plugin.object, game.scene.camera)
        assertSameInstance(plugin.game, game)

        game.scene.camera.remove(plugin)
        XCTAssertFalse(plugin.isActive)
    }
}
