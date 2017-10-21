/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import PlaygroundSupport
import ImagineEngine

class AsteroidBlasterScene: Scene {
    override func setup() {
        backgroundColor = Color(red: 0, green: 0, blue: 0.3, alpha: 1)

        let groundSize = Size(width: size.width, height: 100)
        let ground = Block(size: groundSize, textureCollectionName: "Ground")
        ground.position.x = center.x
        ground.position.y = size.height - groundSize.height / 2
        add(ground)

        let housesGroup = Group.name("Houses")

        for x in stride(from: center.x - 100, to: center.x + 150, by: 50) {
            let house = Actor()
            house.animation = Animation(name: "House", frameCount: 1, frameDuration: 0)
            house.group = housesGroup
            add(house)

            house.position.x = x
            house.position.y = ground.rect.minY - house.size.height / 2
        }

        timeline.repeat(withInterval: 1) { [weak self] in
            guard let scene = self else {
                return
            }

            let asteroid = Actor()
            asteroid.animation = Animation(name: "Asteroid", frameCount: 1, frameDuration: 0)
            scene.add(asteroid)

            let positionRange = scene.size.width - asteroid.size.width
            let randomPosition = Metric(arc4random() % UInt32(positionRange))
            asteroid.position.x = asteroid.size.width / 2 + randomPosition

            asteroid.velocity.dy = 100

            asteroid.events.collidedWithAnyBlock.observe { asteroid in
                asteroid.explode()
            }

            asteroid.events.collided(withActorInGroup: housesGroup).observe { asteroid, house in
                asteroid.explode()

                house.explode().then {
                    guard let scene = self else {
                        return
                    }

                    for actor in scene.actors {
                        if actor.group == housesGroup {
                            return
                        }
                    }

                    scene.reset()
                }
            }

            asteroid.events.clicked.observe { asteroid in
                asteroid.explode()
            }
        }
    }
}

extension Actor {
    @discardableResult func explode() -> ActionToken {
        velocity = .zero

        let explosionAnimation = Animation(
            name: "Explosion",
            frameCount: 7,
            frameDuration: 0.07,
            repeatMode: .never
        )

        return playAnimation(explosionAnimation).then {
            self.remove()
        }
    }
}

let sceneSize = Size(width: 375, height: 667)
let scene = AsteroidBlasterScene(size: sceneSize)
PlaygroundPage.current.liveView = GameViewController(scene: scene)
