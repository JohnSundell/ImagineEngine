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

    func testRect() {
        XCTAssertEqual(actor.rect, .zero)

        actor.position = Point(x: 150, y: 200)
        XCTAssertEqual(actor.rect, Rect(x: 150, y: 200, width: 0, height: 0))

        actor.size = Size(width: 100, height: 300)
        XCTAssertEqual(actor.rect, Rect(x: 100, y: 50, width: 100, height: 300))

        // The actor's rect should be adapted if its scale is changed
        actor.scale = 3
        XCTAssertEqual(actor.rect, Rect(x: 0, y: -250, width: 300, height: 900))
    }

    func testAnimationAutoResizingActor() {
        let imageSizes = [
            Size(width: 200, height: 150),
            Size(width: 300, height: 50),
            Size(width: 100, height: 90)
        ]

        let images = imageSizes.map(ImageMockFactory.makeImage)
        actor.animation = Animation(images: images, frameDuration: 1.5)

        // The actor should directly render the first frame
        XCTAssertEqual(actor.size, imageSizes[0].scaled)

        // Perform a game update to start the animation
        game.update()

        // After 1.5 seconds the second frame should be rendered, and the actor resized
        game.timeTraveler.travel(by: 1.5)
        game.update()
        XCTAssertEqual(actor.size, imageSizes[1].scaled)

        // Same thing for the third frame
        game.timeTraveler.travel(by: 1.5)
        game.update()
        XCTAssertEqual(actor.size, imageSizes[2].scaled)

        // After an additional 1.5 seconds, the initial frame should again be rendered
        game.timeTraveler.travel(by: 1.5)
        game.update()
        XCTAssertEqual(actor.size, imageSizes[0].scaled)
    }

    func testSettingActorInitialSizeFromAnimation() {
        let imageSize = Size(width: 200, height: 150)
        let image = ImageMockFactory.makeImage(withSize: imageSize)

        let actor = Actor()
        actor.animation = Animation(image: image)

        // Before being added to the scene, the actor's size should remain zero
        XCTAssertEqual(actor.size, .zero)

        // As soon as the actor is added, it should be resized (even without an update)
        game.scene.add(actor)
        XCTAssertEqual(actor.size, imageSize.scaled)
    }

    func testAnimatingWithSpriteSheet() {
        let imageSize = Size(width: 300, height: 100)
        let image = ImageMockFactory.makeImage(withSize: imageSize)
        game.textureImageLoader.images["sheet.png"] = image.cgImage

        var animation = Animation(
            spriteSheetNamed: "sheet",
            frameCount: 6,
            rowCount: 2,
            frameDuration: 1
        )
        animation.textureScale = 1

        let actor = Actor()
        actor.animation = animation
        game.scene.add(actor)
        XCTAssertEqual(actor.size, Size(width: 100, height: 50))

        game.timeTraveler.travel(by: 1)
        game.update()
        XCTAssertEqual(actor.size, Size(width: 100, height: 50))

        // Assigning new sprite sheet mid-animation should update the animation
        var newAnimation = Animation(
            spriteSheetNamed: "sheet2",
            frameCount: 6,
            rowCount: 2,
            frameDuration: 1
        )
        newAnimation.textureScale = 1
        actor.animation = newAnimation

        game.update()
        XCTAssertEqual(game.textureImageLoader.imageNames, ["sheet.png", "sheet2.png"])
    }

    func testInitializingWithTextureName() {
        let actor = Actor(textureNamed: "SomeTexture", scale: 1)
        game.scene.add(actor)
        XCTAssertEqual(game.textureImageLoader.imageNames, ["SomeTexture.png"])
    }

    func testTextureNamePrefix() {
        actor.textureNamePrefix = "Prefix"
        actor.animation = Animation(textureNamed: "Texture", scale: 1)

        game.update()
        XCTAssertEqual(game.textureImageLoader.imageNames, ["PrefixTexture.png"])
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

    func testRetrievingPlugin() {
        let pluginsBeforeAdded = actor.plugins(ofType: PluginMock<Actor>.self)
        XCTAssertEqual(pluginsBeforeAdded.count, 0)

        let plugin = PluginMock<Actor>()

        actor.add(plugin)
        XCTAssertTrue(plugin.isActive)

        let plugins = actor.plugins(ofType: PluginMock<Actor>.self)
        XCTAssertEqual(plugins.count, 1)
        assertSameInstance(plugins.first, plugin)

        actor.removePlugins(ofType: PluginMock<Actor>.self)

        let pluginsAfterRemoved = actor.plugins(ofType: PluginMock<Actor>.self)
        XCTAssertEqual(pluginsAfterRemoved.count, 0)
    }

    func testConstrainingToScene() {
        game.scene.size = Size(width: 500, height: 500)

        actor.constraints = [.scene]
        actor.size = Size(width: 100, height: 100)
        actor.position.x = 500
        XCTAssertEqual(actor.position.x, 450)

        actor.position.y = 600
        XCTAssertEqual(actor.position.y, 450)

        // Set actor scale
        actor.scale = 0.5

        actor.position.x = 500
        XCTAssertEqual(actor.position.x, 475)

        actor.position.y = 600
        XCTAssertEqual(actor.position.y, 475)

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

        // When moving the actor away, the least possible distance should be picked
        actor.position = Point(x: 180, y: -190)
        XCTAssertEqual(actor.position, Point(x: 180, y: -200))
        actor.position = Point(x: 190, y: -180)
        XCTAssertEqual(actor.position, Point(x: 200, y: -180))
    }

    func testMovedEventsNotCalledMultipleTimesWhenConstraining() {
        let blockSize = Size(width: 400, height: 400)
        let blockGroup = Group.name("Block")

        let block = Block(size: blockSize, textureCollectionName: "Block")
        block.group = blockGroup
        game.scene.add(block)

        actor.size = Size(width: 100, height: 100)
        actor.position = Point(x: 250, y: 0)
        actor.constraints = [.neverOverlapBlockInGroup(blockGroup)]

        var movedCallCount = 0
        actor.events.moved.observe { movedCallCount += 1 }

        // Moving the actor to overlap the block should not trigger any events
        // since, from the user's perspective, it simply remains at the same poisition
        actor.position.x = 200
        XCTAssertEqual(actor.position.x, 250)
        XCTAssertEqual(movedCallCount, 0)

        // Moving the actor anywhere else should trigger events
        actor.position.x = 300
        XCTAssertEqual(actor.position.x, 300)
        XCTAssertEqual(movedCallCount, 1)
    }

    func testObservingMove() {
        var noValueTriggerCount = 0
        actor.events.moved.observe { noValueTriggerCount += 1 }

        var actorPositions = [Point]()
        var oldPositions = [Point]()
        var newPositions = [Point]()

        actor.events.moved.observe { actor, positions in
            actorPositions.append(actor.position)
            oldPositions.append(positions.old)
            newPositions.append(positions.new)
        }

        actor.position.x += 100
        actor.position.y += 50

        XCTAssertEqual(noValueTriggerCount, 2)
        XCTAssertEqual(actorPositions, [Point(x: 100, y: 0), Point(x: 100, y: 50)])
        XCTAssertEqual(oldPositions, [.zero, Point(x: 100, y: 0)])
        XCTAssertEqual(newPositions, [Point(x: 100, y: 0), Point(x: 100, y: 50)])
    }

    func testEnteredScene() {
        // Create actor and place in center of scene
        let actor = Actor()
        actor.position = game.scene.center
        game.scene.add(actor)

        var enterSceneCount = 0
        actor.events.enteredScene.observe { enterSceneCount += 1 }

        // Move actor outside scene
        actor.position.x = -100
        XCTAssertFalse(actor.isWithinScene)
        XCTAssertEqual(enterSceneCount, 0)

        // Now move actor back into scene
        actor.position.x = 0
        XCTAssertTrue(actor.isWithinScene)
        XCTAssertEqual(enterSceneCount, 1)
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

    func testObservingRotationChange() {
        var noValueTriggerCount = 0
        actor.events.rotated.observe { noValueTriggerCount += 1 }

        actor.rotation = 1
        actor.rotation = 2

        // Setting rotation to same value should not generate event
        actor.rotation = 2

        XCTAssertEqual(noValueTriggerCount, 2)
        XCTAssertEqual(actor.layer.rotation, 2, accuracy: 0.001)
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

        actor.position = Point(x: 300, y: 300)

        // A scaled down actor should use its scale and avoid a collision
        actor.scale = 0.5
        actor.position = Point(x: 90, y: 90)
        XCTAssertEqual(numberOfCollisions, 3)

        // Scaling back up should trigger a collision
        actor.scale = 1
        XCTAssertEqual(numberOfCollisions, 4)

        // A scaled up actor should trigger a collision from farther away.
        actor.position = Point(x: 300, y: 300)
        actor.scale = 1.5
        actor.position = Point(x: 120, y: 120)
        XCTAssertEqual(numberOfCollisions, 5)

        // Setting a hitbox should override the scaling effect.
        actor.hitboxSize = Size(width: 25, height: 25)
        actor.position = Point(x: 90, y: 90)
        XCTAssertEqual(numberOfCollisions, 5)
    }

    func testObservingCollisionWithActorInGroup() {
        actor.size = Size(width: 100, height: 100)
        actor.position = Point(x: 300, y: 300)

        let group = Group.name("ActorGroup")

        let otherActor = Actor(size: Size(width: 100, height: 100))
        otherActor.group = group
        game.scene.add(otherActor)

        var numberOfCollisions = 0

        actor.events.collided(withActorInGroup: group).observe {
            numberOfCollisions += 1
        }

        XCTAssertEqual(numberOfCollisions, 0)

        // Move the actor to collide with the other actor
        actor.position = otherActor.position
        XCTAssertEqual(numberOfCollisions, 1)

        // Then move the other actor away, then back, which should also trigger a collision
        otherActor.position = Point(x: 300, y: 300)
        otherActor.position = actor.position
        XCTAssertEqual(numberOfCollisions, 2)
    }

    func testShouldNotCollideWithItself() {
        let group = Group.name("ActorGroup")

        actor.size = Size(width: 100, height: 100)
        actor.position = Point(x: 300, y: 300)
        actor.group = group

        var numberOfCollisions = 0

        actor.events.collided(withActorInGroup: group).observe {
            numberOfCollisions += 1
        }

        XCTAssertEqual(numberOfCollisions, 0)

        // Move the actor to trigger collision detection
        actor.position = Point(x: 400, y: 400)

        // Actor should not collide with itself
        XCTAssertEqual(numberOfCollisions, 0)
    }

    func testObservingCollisionWithBlockInGroup() {
        actor.size = Size(width: 100, height: 100)
        actor.position = Point(x: 300, y: 300)

        let group = Group.name("BlockGroup")

        let block = Block(size: Size(width: 100, height: 100), spriteSheetName: "Block")
        block.group = group
        game.scene.add(block)

        var numberOfCollisions = 0

        actor.events.collided(withBlockInGroup: group).observe {
            numberOfCollisions += 1
        }

        XCTAssertEqual(numberOfCollisions, 0)

        // Move the actor to collide with the block
        actor.position = block.position
        XCTAssertEqual(numberOfCollisions, 1)

        // Then move the other actor away, then back, which should also trigger a collision
        block.position = Point(x: 300, y: 300)
        block.position = actor.position
        XCTAssertEqual(numberOfCollisions, 2)
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

    func testLayerAndSceneReferenceRemovedWhenActorIsRemoved() {
        XCTAssertNotNil(actor.layer.superlayer)
        XCTAssertNotNil(actor.scene)

        actor.remove()
        XCTAssertNil(actor.layer.superlayer)
        XCTAssertNil(actor.scene)
    }
}

private extension Size {
    // TODO: Needed until we find a better way of figuring out the image scale factor on macOS
    var scaled: Size {
        #if (os(iOS) || os(tvOS))
            return self
        #else
            let scale = Screen.mainScreenScale
            return Size(width: self.width / scale, height: self.height / scale)
        #endif
    }
}
