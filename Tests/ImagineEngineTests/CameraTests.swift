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
