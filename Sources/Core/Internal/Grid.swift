/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class Grid {
    private(set) var actors = Set<Actor>()
    private(set) var blocks = Set<Block>()
    private(set) var labels = Set<Label>()
    private var tiles = [Index : Tile]()
    private var nextZIndex = 0

    func add(_ actor: Actor, in scene: Scene) {
        guard actors.insert(actor).inserted else {
            return
        }

        actorRectDidChange(actor, in: scene)
        assignZIndexIfNeeded(to: actor)
    }

    func remove(_ actor: Actor) {
        guard actors.remove(actor) != nil else {
            return
        }

        for actorInContact in actor.actorsInContact {
            actorInContact.actorsInContact.remove(actor)
        }

        for tile in actor.gridTiles {
            tile.actors.remove(actor)
        }

        actor.actorsInContact = []
        actor.gridTiles = []
    }

    func add(_ block: Block) {
        guard blocks.insert(block).inserted else {
            return
        }

        blockRectDidChange(block)
        assignZIndexIfNeeded(to: block)
    }

    func remove(_ block: Block) {
        guard blocks.remove(block) != nil else {
            return
        }

        for tile in block.gridTiles {
            tile.blocks.remove(block)
        }

        block.gridTiles = []
    }

    func add(_ label: Label) {
        guard labels.insert(label).inserted else {
            return
        }

        assignZIndexIfNeeded(to: label)
    }

    func remove(_ label: Label) {
        labels.remove(label)
    }

    func actors(at point: Point) -> [Actor] {
        let index = Index(x: point.x, y: point.y)

        guard let tile = tiles[index] else {
            return []
        }

        let actors = tile.actors.filter { $0.isHitTestingEnabled }
        return actors.sorted { $0.zIndex > $1.zIndex }
    }

    func actorRectDidChange(_ actor: Actor, in scene: Scene) {
        if actor.constraints.contains(.scene) {
            var adjustedPosition = actor.position
            adjustedPosition.x = min(scene.size.width - actor.size.width / 2,
                                     max(actor.size.width / 2, actor.position.x))
            adjustedPosition.y = min(scene.size.height - actor.size.height / 2,
                                     max(actor.size.height / 2, actor.position.y))

            if adjustedPosition != actor.position {
                actor.position = adjustedPosition
                return
            }
        }

        var tilesExited = actor.gridTiles
        actor.gridTiles = []

        forEachTile(within: actor.rect) { tile, isNew in
            if !isNew {
                tilesExited.remove(tile)
                performCollisionDetection(for: actor, in: tile)
            }

            tile.actors.insert(actor)
            actor.gridTiles.insert(tile)
        }

        for tile in tilesExited {
            tile.actors.remove(actor)

            for otherActor in tile.actors {
                guard otherActor.actorsInContact.remove(actor) != nil else {
                    continue
                }

                actor.actorsInContact.remove(otherActor)
            }
        }
    }

    func blockRectDidChange(_ block: Block) {
        var tilesExited = block.gridTiles
        block.gridTiles = []

        forEachTile(within: block.rect) { tile, isNew in
            if !isNew {
                tilesExited.remove(tile)
            }

            tile.blocks.insert(block)
            block.gridTiles.insert(tile)
        }

        for tile in tilesExited {
            tile.blocks.remove(block)
        }
    }

    // MARK: - Private

    private func assignZIndexIfNeeded(to object: ZIndexed) {
        guard object.zIndex == 0 else {
            return
        }

        object.zIndex = nextZIndex
        nextZIndex += 1
    }

    private func forEachTile(within rect: Rect, run closure: (_ tile: Tile, _ isNew: Bool) -> Void) {
        let startIndex = Index(x: rect.minX, y: rect.minY)
        let endIndex = Index(x: rect.maxX, y: rect.maxY)

        for x in startIndex.x...endIndex.x {
            for y in startIndex.y...endIndex.y {
                let index = Index(x: x, y: y)

                if let existingTile = tiles[index] {
                    closure(existingTile, false)
                } else {
                    let tile = Tile()
                    tiles[index] = tile
                    closure(tile, true)
                }
            }
        }
    }

    private func performCollisionDetection(for actor: Actor, in tile: Tile) {
        guard shouldPerformCollisionDetection(for: actor) else {
            return
        }

        for otherActor in tile.actors {
            guard shouldPerformCollisionDetection(for: otherActor) else {
                continue
            }

            guard !actor.actorsInContact.contains(otherActor) else {
                continue
            }

            guard actor.rectForCollisionDetection.intersects(otherActor.rectForCollisionDetection) else {
                continue
            }

            handleCollisionBetween(actor, and: otherActor)
            handleCollisionBetween(otherActor, and: actor)
        }

        for block in tile.blocks {
            guard actor.rectForCollisionDetection.intersects(block.rect) else {
                continue
            }

            handleCollisionBetween(actor, and: block)

            if let group = block.group {
                if actor.constraints.contains(.neverOverlapBlockInGroup(group)) {
                    move(actor, awayFrom: block)
                }
            }
        }
    }

    private func shouldPerformCollisionDetection(for actor: Actor) -> Bool {
        return actor.isCollisionDetectionEnabled && actor.scene != nil
    }

    private func handleCollisionBetween(_ actorA: Actor, and actorB: Actor) {
        actorA.events.collided(with: actorB).trigger(with: actorB)
        actorA.events.collidedWithAnyActor.trigger(with: actorB)

        if let group = actorB.group {
            actorA.events.collided(withActorInGroup: group).trigger(with: actorB)
        }

        actorA.actorsInContact.insert(actorB)
    }

    private func handleCollisionBetween(_ actor: Actor, and block: Block) {
        actor.events.collidedWithAnyBlock.trigger(with: block)

        if let group = block.group {
            actor.events.collided(withBlockInGroup: group).trigger(with: block)
        }
    }

    private func move(_ actor: Actor, awayFrom block: Block) {
        let actorRect = actor.rectForCollisionDetection
        let distanceX: Metric
        let distanceY: Metric

        if actor.position.x > block.rect.midX {
            distanceX = block.rect.maxX - actorRect.minX
        } else {
            distanceX = block.rect.minX - actorRect.maxX
        }

        if actor.position.y > block.rect.midY {
            distanceY = block.rect.maxY - actorRect.minY
        } else {
            distanceY = block.rect.minY - actorRect.maxY
        }

        if abs(distanceX) < abs(distanceY) {
            actor.position.x += distanceX
        } else {
            actor.position.y += distanceY
        }
    }
}

internal extension Grid {
    final class Tile: InstanceHashable {
        fileprivate static let size = Metric(50)

        var actors = Set<Actor>()
        var blocks = Set<Block>()
    }
}

private extension Grid {
    struct Index: Hashable {
        static func ==(lhs: Index, rhs: Index) -> Bool {
            return lhs.x == rhs.x && lhs.y == rhs.y
        }

        let x: Int
        let y: Int
        var hashValue: Int { return x ^ y }
    }
}

extension Grid.Index {
    init(x: Metric, y: Metric) {
        self.x = Int(floor(x / Grid.Tile.size))
        self.y = Int(floor(y / Grid.Tile.size))
    }
}
