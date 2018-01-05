/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class Grid: Activatable {
    private(set) var actors = Set<Actor>()
    private(set) var blocks = Set<Block>()
    private(set) var labels = Set<Label>()
    private var tiles = [Index : Tile]()
    private var nextZIndex = 0
    private weak var game: Game?

    func add(_ actor: Actor, in scene: Scene) {
        guard actors.insert(actor).inserted else {
            return
        }

        actorRectDidChange(actor, in: scene)
        assignZIndexIfNeeded(to: actor)

        actor.scene = scene
        game.map(actor.activate)
    }

    func remove(_ actor: Actor) {
        guard actors.remove(actor) != nil else {
            return
        }

        actor.deactivate()

        for actorInContact in actor.actorsInContact {
            actorInContact.actorsInContact.remove(actor)
        }

        for blockInContact in actor.blocksInContact {
            blockInContact.actorsInContact.remove(actor)
        }

        for tile in actor.gridTiles {
            tile.actors.remove(actor)
        }

        actor.actorsInContact = []
        actor.gridTiles = []
    }

    func add(_ block: Block, in scene: Scene) {
        guard blocks.insert(block).inserted else {
            return
        }

        blockRectDidChange(block)
        assignZIndexIfNeeded(to: block)

        block.scene = scene
        game.map(block.activate)
    }

    func remove(_ block: Block) {
        guard blocks.remove(block) != nil else {
            return
        }

        block.deactivate()

        for actorInContact in block.actorsInContact {
            actorInContact.blocksInContact.remove(block)
        }

        for tile in block.gridTiles {
            tile.blocks.remove(block)
        }

        block.gridTiles = []
    }

    func add(_ label: Label, in scene: Scene) {
        guard labels.insert(label).inserted else {
            return
        }

        assignZIndexIfNeeded(to: label)
        labelRectDidChange(label)

        label.scene = scene
        game.map(label.activate)
    }

    func remove(_ label: Label) {
        guard labels.remove(label) != nil else {
            return
        }

        label.deactivate()
        label.gridTiles.forEach(label.remove)
    }

    func actors(at point: Point) -> [Actor] {
        let index = Index(x: point.x, y: point.y)

        guard let tile = tiles[index] else {
            return []
        }

        let actors = tile.actors.filter { actor in
            return actor.isHitTestingEnabled &&
                   actor.rect.contains(point)
        }

        return actors.sorted { $0.zIndex > $1.zIndex }
    }

    func labels(at point: Point) -> [Label] {
        let index = Index(x: point.x, y: point.y)

        guard let tile = tiles[index] else {
            return []
        }

        let labels = tile.labels.filter { label in
            return label.rect.contains(point)
        }

        return labels.sorted { $0.zIndex > $1.zIndex }
    }

    func actorRectDidChange(_ actor: Actor, in scene: Scene) {
        if actor.constraints.contains(.scene) {
            var adjustedPosition = actor.position
            adjustedPosition.x = min(scene.size.width - actor.rect.width / 2,
                                     max(actor.rect.width / 2, actor.position.x))
            adjustedPosition.y = min(scene.size.height - actor.rect.height / 2,
                                     max(actor.rect.height / 2, actor.position.y))

            if adjustedPosition != actor.position {
                actor.position = adjustedPosition
                return
            }
        }

        updateTiles(for: actor, collisionDetector: performCollisionDetection)
    }

    func blockRectDidChange(_ block: Block) {
        updateTiles(for: block, collisionDetector: performCollisionDetection)
    }

    func labelRectDidChange(_ label: Label) {
        updateTiles(for: label, collisionDetector: nil)
    }

    func handleClick(at point: Point) {
        for actor in actors(at: point) {
            actor.events.clicked.trigger()
        }

        for label in labels(at: point) {
            label.events.clicked.trigger()
        }
    }

    func removeAllObjects() {
        for actor in actors {
            actor.remove()
        }

        for block in blocks {
            block.remove()
        }

        for label in labels {
            label.remove()
        }
    }

    // MARK: - Activatable

    func activate(in game: Game) {
        self.game = game

        for actor in actors {
            actor.activate(in: game)
        }

        for block in blocks {
            block.activate(in: game)
        }

        for label in labels {
            label.activate(in: game)
        }
    }

    func deactivate() {
        game = nil

        for actor in actors {
            actor.deactivate()
        }

        for block in blocks {
            block.deactivate()
        }

        for label in labels {
            label.deactivate()
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

    private func updateTiles<O: SceneObject>(for object: O, collisionDetector: ((O, Tile) -> Void)?) {
        let rect = object.rect
        let startIndex = Index(x: rect.minX, y: rect.minY)
        let endIndex = Index(x: rect.maxX, y: rect.maxY)

        var tilesExited = object.gridTiles

        for x in startIndex.x...endIndex.x {
            for y in startIndex.y...endIndex.y {
                let index = Index(x: x, y: y)

                if let existingTile = tiles[index] {
                    object.add(to: existingTile)
                    tilesExited.remove(existingTile)
                    collisionDetector?(object, existingTile)
                } else {
                    let tile = Tile()
                    tiles[index] = tile
                    object.add(to: tile)
                }
            }
        }

        tilesExited.forEach(object.remove)
    }

    private func performCollisionDetection(for actor: Actor, in tile: Tile) {
        guard let mode = resolveCollisionDetectionMode(for: actor) else {
            return
        }

        switch mode {
        case .full:
            detectCollisions(between: actor, and: tile.actors)
        case .constraintsOnly:
            break
        }

        for block in tile.blocks {
            guard let blockGroup = block.group else {
                continue
            }

            detectCollision(between: actor, and: block, blockGroup: blockGroup, mode: mode)
        }
    }

    private func performCollisionDetection(for block: Block, in tile: Tile) {
        guard let group = block.group else {
            return
        }

        for actor in tile.actors {
            guard let mode = resolveCollisionDetectionMode(for: actor) else {
                continue
            }

            detectCollision(between: actor, and: block, blockGroup: group, mode: mode)
        }
    }

    private func resolveCollisionDetectionMode(for actor: Actor) -> CollisionDetectionMode? {
        if actor.isCollisionDetectionEnabled {
            if actor.isCollisionDetectionActive || actor.group != nil {
                return .full
            }
        }

        if !actor.constraints.isEmpty {
            return .constraintsOnly
        }

        return nil
    }

    private func detectCollisions(between actor: Actor, and otherActors: Set<Actor>) {
        for otherActor in otherActors {
            guard otherActor !== actor else {
                continue
            }

            guard otherActor.scene != nil else {
                continue
            }

            guard actor.scene != nil else {
                continue
            }

            switch resolveCollisionDetectionMode(for: otherActor) {
            case .full?:
                break
            case nil, .constraintsOnly?:
                continue
            }

            guard !actor.actorsInContact.contains(otherActor) else {
                continue
            }

            guard actor.rectForCollisionDetection.intersects(otherActor.rectForCollisionDetection) else {
                continue
            }

            handleCollision(between: actor, and: otherActor)
            handleCollision(between: otherActor, and: actor)
        }
    }

    private func detectCollision(between actor: Actor,
                                 and block: Block,
                                 blockGroup: Group,
                                 mode: CollisionDetectionMode) {
        guard actor.rectForCollisionDetection.intersects(block.rect) else {
            return
        }

        switch mode {
        case .full:
            guard !actor.blocksInContact.contains(block) else {
                break
            }

            actor.blocksInContact.insert(block)
            block.actorsInContact.insert(actor)
            actor.events.collided(withBlockInGroup: blockGroup).trigger(with: block)
        case .constraintsOnly:
            break
        }

        if let group = block.group {
            if actor.constraints.contains(.neverOverlapBlockInGroup(group)) {
                move(actor, awayFrom: block)
            }
        }
    }

    private func handleCollision(between actorA: Actor, and actorB: Actor) {
        actorA.events.collided(with: actorB).trigger(with: actorB)

        if let group = actorB.group {
            actorA.events.collided(withActorInGroup: group).trigger(with: actorB)
        }

        actorA.actorsInContact.insert(actorB)
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
        var labels = Set<Label>()
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

    enum CollisionDetectionMode {
        case full
        case constraintsOnly
    }
}

extension Grid.Index {
    init(x: Metric, y: Metric) {
        self.x = Int(floor(x / Grid.Tile.size))
        self.y = Int(floor(y / Grid.Tile.size))
    }
}
