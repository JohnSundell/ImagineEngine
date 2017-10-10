/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
@testable import ImagineEngine

final class ActorTests: XCTestCase {
    private var actor: Actor!
    private var game: GameMock!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        actor = Actor()
        game = GameMock()
        game.scene.add(actor)
    }

    // MARK: - Tests

    func testAnimationAutoResizingActor() {
        let imageSize = Size(width: 200, height: 150)
        let image = ImagineMockFactory.makeImage(withSize: imageSize)

        actor.animation = Animation(image: image)
        game.update()

        XCTAssertEqual(actor.size, imageSize)
    }

    func testTextureNamePrefix() {
        actor.textureNamePrefix = "Prefix"

        var animation = Animation(textureNamed: "Texture")
        animation.textureScale = 1
        actor.animation = animation

        game.update()
        XCTAssertEqual(game.textureImageLoader.imageNames, ["PrefixTexture"])
    }

    func testAddingAndRemovingPlugin() {
        let plugin = PluginMock<Actor>()

        actor.add(plugin)
        XCTAssertTrue(plugin.isActive)
        assertSameInstance(plugin.object, actor)
        assertSameInstance(plugin.game, game)

        actor.remove(plugin)
        XCTAssertFalse(plugin.isActive)
    }

    func testConstrainingToScene() {
        game.scene.size = Size(width: 500, height: 500)

        actor.constraints = [.scene]
        actor.size = Size(width: 100, height: 100)
        actor.position.x = 500
        XCTAssertEqual(actor.position.x, 450)

        actor.position.y = 600
        XCTAssertEqual(actor.position.y, 450)

        // Removing the constraint should free the actor to move outside of the scene
        actor.constraints = []
        actor.position.x = 700
        XCTAssertEqual(actor.position.x, 700)
    }

    func testConstrainingToNotOverlapBlock() {
        let blockSize = Size(width: 300, height: 300)
        let blockGroup = Group.name("Block")

        let block = Block(size: blockSize, textureCollectionName: "Block")
        block.group = blockGroup
        game.scene.add(block)

        actor.size = Size(width: 100, height: 100)
        actor.position = Point(x: 300, y: 0)
        actor.constraints = [.neverOverlapBlockInGroup(blockGroup)]

        // Approaching from the right should stop the actor at the block's right edge
        actor.position = Point(x: 180, y: 0)
        XCTAssertEqual(actor.position.x, 200)

        // Approaching from the right should stop the actor at the block's right edge
        actor.position = Point(x: -130, y: 0)
        XCTAssertEqual(actor.position.x, -200)
        
        // Approaching from the top should stop the actor at the block's top edge
        actor.position = Point(x: 0, y: -130)
        XCTAssertEqual(actor.position.y, -200)

        // Approaching from the bottom should stop the actor at the block's bottom edge
        actor.position = Point(x: 0, y: 180)
        XCTAssertEqual(actor.position.y, 200)
    }

    func testObservingMove() {
        var noValueTriggerCount = 0
        actor.events.moved.observe { noValueTriggerCount += 1 }

        var positions = [Point]()
        actor.events.moved.observe { positions.append($0.position) }

        actor.position.x += 100
        actor.position.y += 50

        XCTAssertEqual(noValueTriggerCount, 2)
        XCTAssertEqual(positions, [Point(x: 100, y: 0), Point(x: 100, y: 50)])
    }

    func testObservingResize() {
        var noValueTriggerCount = 0
        actor.events.resized.observe { noValueTriggerCount += 1 }

        var sizes = [Size]()
        actor.events.resized.observe { sizes.append($0.size) }

        actor.size.width += 100
        actor.size.height += 50

        XCTAssertEqual(noValueTriggerCount, 2)
        XCTAssertEqual(sizes, [Size(width: 100, height: 0),
                               Size(width: 100, height: 50)])
    }

    func testObservingVelocityChange() {
        var noValueTriggerCount = 0
        actor.events.velocityChanged.observe { noValueTriggerCount += 1 }

        var velocities = [Vector]()
        actor.events.velocityChanged.observe { velocities.append($0.velocity) }

        actor.velocity.dx += 100
        actor.velocity.dy += 50

        XCTAssertEqual(noValueTriggerCount, 2)
        XCTAssertEqual(velocities, [Vector(dx: 100, dy: 0), Vector(dx: 100, dy: 50)])
    }

    func testObservingCollisionsWithOtherActor() {
        let otherActor = Actor(size: Size(width: 100, height: 100))
        game.scene.add(otherActor)

        actor.size = otherActor.size
        actor.position = Point(x: 300, y: 300)

        var numberOfCollisions = 0

        actor.events.collided(with: otherActor).observe {
            numberOfCollisions += 1
        }

        XCTAssertEqual(numberOfCollisions, 0)

        // Actors start intersecting = first collision
        actor.position = Point(x: 50, y: 50)
        XCTAssertEqual(numberOfCollisions, 1)

        // Moving any of the actors while overlapped should
        // not trigger additional collisions
        actor.position = Point(x: 60, y: 30)
        otherActor.position = Point(x: 10, y: 10)
        XCTAssertEqual(numberOfCollisions, 1)

        // Moving the actors away from each other, and then back again
        // should trigger another collision. Also, this time we're moving
        // the other actor to ensure event symmetry.
        actor.position = Point(x: 300, y: 300)
        XCTAssertEqual(numberOfCollisions, 1)
        otherActor.position = actor.position
        XCTAssertEqual(numberOfCollisions, 2)

        // Removing one of the actors should prevent further collisions
        otherActor.position = .zero
        otherActor.remove()
        actor.position = .zero
        XCTAssertEqual(numberOfCollisions, 2)

        // Adding it back again should re-enable collisions
        actor.position = Point(x: 300, y: 300)
        game.scene.add(otherActor)
        actor.position = .zero
        XCTAssertEqual(numberOfCollisions, 3)
    }

    func testAssigningZIndex() {
        XCTAssertEqual(actor.zIndex, 0)

        let secondActor = Actor()
        game.scene.add(secondActor)
        XCTAssertEqual(secondActor.zIndex, 1)

        let thirdActor = Actor()
        game.scene.add(thirdActor)
        XCTAssertEqual(thirdActor.zIndex, 2)
    }

    func testExplicitZIndexNotOverriden() {
        let actor = Actor()
        actor.zIndex = 500
        game.scene.add(actor)
        XCTAssertEqual(actor.zIndex, 500)
    }
}
