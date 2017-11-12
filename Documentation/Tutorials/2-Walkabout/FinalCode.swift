/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import PlaygroundSupport
import ImagineEngine

class WalkaboutScene: Scene {
    override func setup() {
        let ground = Block(size: size, spriteSheetName: "Ground")
        ground.position = center
        add(ground)

        let player = Actor()
        player.position = center
        add(player)

        player.textureNamePrefix = "Player/"

        let idleAnimation = Animation(name: "Idle", frameCount: 1, frameDuration: 1)
        player.animation = idleAnimation

        var moveToken: ActionToken?

        events.clicked.observe { _, point in
            moveToken?.cancel()

            let speed: Metric = 100
            let horizontalTarget = Point(x: point.x, y: player.position.y)
            let horizontalDuration = TimeInterval(abs(player.position.x - point.x) / speed)
            let verticalTarget = Point(x: point.x, y: point.y)
            let verticalDuration = TimeInterval(abs(player.position.y - point.y) / speed)

            moveToken = player.move(to: horizontalTarget, duration: horizontalDuration)
                              .then(player.move(to: verticalTarget, duration: verticalDuration))
                              .then(player.playAnimation(idleAnimation))
        }

        player.events.moved.addObserver(self) { scene, player, positions in
            let directionName: String

            if positions.new.x < positions.old.x {
                directionName = "Left"
            } else if positions.new.x > positions.old.x {
                directionName = "Right"
            } else if positions.new.y > positions.old.y {
                directionName = "Down"
            } else {
                directionName = "Up"
            }

            player.animation = Animation(
                spriteSheetNamed: "Walking/\(directionName)",
                frameCount: 4,
                rowCount: 1,
                frameDuration: 0.15
            )

            scene.camera.position = positions.new
        }

        player.constraints = [.scene]
        camera.constrainedToScene = true
    }
}

let sceneSize = Size(width: 768, height: 768)
let scene = WalkaboutScene(size: sceneSize)
PlaygroundPage.current.liveView = GameViewController(scene: scene)
