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

    func testConstrainingToScene() {
        game.view.frame.size = Size(width: 500, height: 300)

        let scene = Scene(size: Size(width: 500, height: 300))
        game.scene = scene

        // By default, the camera is not constrained to the scene and can move outside it
        scene.camera.position = Point(x: -2000, y: -1000)
        XCTAssertEqual(scene.camera.position, Point(x: -2000, y: -1000))

        // When turning on the constraint, the camera should move within the scene
        scene.camera.constrainedToScene = true
        XCTAssertEqual(scene.camera.position, Point(x: 250, y: 150))

        // From now on the camera shouldn't be able to move outside of the scene
        scene.camera.position.x += 100
        scene.camera.position.y += 100
        XCTAssertEqual(scene.camera.position, Point(x: 250, y: 150))

        scene.camera.position.x -= 100
        scene.camera.position.y -= 100
        XCTAssertEqual(scene.camera.position, Point(x: 250, y: 150))

        // If the scene becomes smaller than the viewport, constraints are no longer evaluated
        scene.size = Size(width: 100, height: 200)
        scene.camera.position = Point(x: -2000, y: -1000)
        XCTAssertEqual(scene.camera.position, Point(x: -2000, y: -1000))
    }

    func testResizeEventTrigger() {
        let scene = Scene(size: Size(width: 500, height: 300))
        var resizeTriggerCount = 0
        scene.camera.events.resized.observe { resizeTriggerCount += 1 }

        XCTAssertEqual(resizeTriggerCount, 0)

        // Set view frame and add scene to game thus resizing the camera
        game.view.frame.size = Size(width: 250, height: 150)
        game.scene = scene

        XCTAssertEqual(resizeTriggerCount, 1)

        // Set view frame back to original size to ensure the resize event is untriggered
        game.view.frame.size = Size(width: 250, height: 150)
        XCTAssertEqual(resizeTriggerCount, 1)
    }

    func testObservingMove() {
        let scene = Scene(size: Size(width: 500, height: 500))

        var noValueTriggerCount = 0
        scene.camera.events.moved.observe { noValueTriggerCount += 1 }

        var cameraPositions = [Point]()
        var oldPositions = [Point]()
        var newPositions = [Point]()

        scene.camera.events.moved.observe { actor, positions in
            cameraPositions.append(actor.position)
            oldPositions.append(positions.old)
            newPositions.append(positions.new)
        }

        scene.camera.position.x += 100
        scene.camera.position.y += 50

        XCTAssertEqual(noValueTriggerCount, 2)
        XCTAssertEqual(cameraPositions, [Point(x: 350, y: 250), Point(x: 350, y: 300)])
        XCTAssertEqual(oldPositions, [Point(x: 250, y: 250), Point(x: 350, y: 250)])
        XCTAssertEqual(newPositions, [Point(x: 350, y: 250), Point(x: 350, y: 300)])
    }

    func testObservingClick() {
        var clickedPoints = [Point]()

        game.scene.camera.events.clicked.observe { _, point in
            clickedPoints.append(point)
        }

        game.simulateClick(at: Point(x: 10, y: 20))
        XCTAssertEqual(clickedPoints, [Point(x: 10, y: 20)])

        game.simulateClick(at: Point(x: 30, y: 40))
        XCTAssertEqual(clickedPoints, [Point(x: 10, y: 20), Point(x: 30, y: 40)])
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
