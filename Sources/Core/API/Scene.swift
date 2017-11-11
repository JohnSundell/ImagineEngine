/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation   

/**
 *  Class representing a scene in an Imagine Engine game
 *
 *  Scenes are used to present your game content, and usually represent
 *  individual screens or levels in a game. A scene is activated once
 *  it's added to a running game, and deactivated once it's removed.
 *
 *  You can add game objects such as actors, labels and blocks to a scene,
 *  and it has a camera that enables you to move the viewport around.
 *
 *  You can also choose to subclass this class to add your own properties
 *  to keep track of your game's state.
 */
open class Scene: Pluggable, Activatable {
    /// The game that the scene currently belongs to.
    public private(set) var game: Game?
    /// The scene's camera. Can be used to move the visible area of the scene.
    public private(set) var camera: Camera
    /// A colleciton of events that can be used to observe the scene.
    public private(set) lazy var events = SceneEventCollection(object: self)
    /// Whether the scene is currently paused (which will pause all of its objects).
    public var isPaused = false { didSet { pauseStatusDidChange() } }
    /// The actors that are currently added to the scene.
    public var actors: Set<Actor> { return grid.actors }
    /// The blocks that are currently added to the scene.
    public var blocks: Set<Block> { return grid.blocks }
    /// The labels that are currently added to the scene.
    public var labels: Set<Label> { return grid.labels }
    /// The scene's timeline, which can be used to schedule future events & logic.
    public private(set) var timeline = Timeline()
    /// The scene's texture manager, that keeps track of loaded textures.
    public let textureManager = TextureManager()
    /// The current size of the scene
    public var size: Size { didSet { sizeDidChange() } }
    /// The insets that make up the area that is safe to put content in, to avoid the notch
    /// & home indicator on iPhone X (can be observed using the safeAreaInsetsChanged event)
    public internal(set) var safeAreaInsets = EdgeInsets() { didSet { safeAreaInsetsDidChange(from: oldValue) } }
    /// The scene's background color (default = `.black`)
    public var backgroundColor = Color.black { didSet { backgroundColorDidChange() } }

    private let layer = Layer()
    private var grid = Grid()
    private let pluginManager = PluginManager()
        
    // MARK: - Initializer

    /// Initialize an instance with a given size
    public init(size: Size) {
        self.size = size

        camera = Camera(layer: layer, sceneSize: size)
        camera.position = Point(x: size.width / 2, y: size.height / 2)

        layer.isOpaque = true
        sizeDidChange()
        setup()
    }

    // MARK: - Override points

    /// Called when the scene was created or after it was reset.
    /// Put your code that sets up the scene in its initial state here.
    open func setup() {}

    /// Called when the scene was activated and will start running.
    /// Put your code that starts your game here.
    open func activate() {}

    // MARK: - Scene API

    /// Reset the scene
    /// Calling this will remove all game objects from the scene, and
    /// reset it to its initial state. Once the reset has been completed,
    /// the `setup()` and `activate()` methods will be called.
    public func reset() {
        actors.forEach(deactivate)
        blocks.forEach(deactivate)
        labels.forEach(deactivate)
        pluginManager.deactivate()

        camera = Camera(layer: layer, sceneSize: size)
        camera.position = Point(x: size.width / 2, y: size.height / 2)

        events = SceneEventCollection(object: self)
        grid = Grid()
        timeline = Timeline()

        game.map(timeline.activate)
        game.map(camera.activate)
        game.map(pluginManager.activate)

        setup()
        activate()
    }

    // MARK: - Actor API

    /// Add an actor to the scene
    public func add(_ actor: Actor) {
        actor.scene = self
        
        grid.add(actor, in: self)
        layer.addSublayer(actor.layer)
        game.map(actor.activate)
    }

    /// Remove an actor from the scene
    public func remove(_ actor: Actor) {
        deactivate(actor)
        grid.remove(actor)
    }

    /// Get all actors which rects intersect a given point
    public func actors(at point: Point) -> [Actor] {
        return grid.actors(at: point)
    }

    // MARK: - Block API

    /// Add a block to the scene
    public func add(_ block: Block) {
        block.scene = self

        grid.add(block)
        layer.addSublayer(block.layer)
        game.map(block.activate)
    }

    /// Remove a block from the scene
    public func remove(_ block: Block) {
        deactivate(block)
        grid.remove(block)
    }

    // MARK: - Label API

    /// Add a label to the scene
    public func add(_ label: Label) {
        label.scene = self

        grid.add(label)
        layer.addSublayer(label.layer)
        game.map(label.activate)
    }

    /// Remove a label from the scene
    public func remove(_ label: Label) {
        deactivate(label)
        grid.remove(label)
    }

    // MARK: - Pluggable

    @discardableResult public func add<P: Plugin>(_ plugin: @autoclosure () -> P,
                                                  reuseExistingOfSameType: Bool) -> P where P.Object == Scene {
        return pluginManager.add(plugin, for: self, reuseExistingOfSameType: reuseExistingOfSameType)
    }

    public func plugins<P: Plugin>(ofType type: P.Type) -> [P] where P.Object == Scene {
        return pluginManager.plugins(ofType: type)
    }

    public func remove<P: Plugin>(_ plugin: P) where P.Object == Scene {
        pluginManager.remove(plugin, from: self)
    }

    public func removePlugins<P: Plugin>(ofType type: P.Type) where P.Object == Scene {
        pluginManager.removePlugins(ofType: type, from: self)
    }

    // MARK: - Activatable
    
    internal func activate(in game: Game) {
        self.game = game
        
        game.view.makeLayerIfNeeded().addSublayer(layer)

        camera.activate(in: game)
        timeline.activate(in: game)
        pluginManager.activate(in: game)

        for actor in grid.actors {
            actor.activate(in: game)
        }

        for block in grid.blocks {
            block.activate(in: game)
        }

        for label in grid.labels {
            label.activate(in: game)
        }

        activate()
    }
    
    internal func deactivate() {
        layer.removeFromSuperlayer()

        camera.deactivate()
        timeline.deactivate()
        pluginManager.deactivate()

        for actor in grid.actors {
            actor.deactivate()
        }

        for label in grid.labels {
            label.deactivate()
        }
    }

    // MARK: - Internal

    internal func requestUpdate(for object: Updatable) {
        let wrapper = UpdatableWrapper(updatable: object)
        timeline.schedule(wrapper, delay: 0)
    }

    internal func actorRectDidChange(_ actor: Actor) {
        grid.actorRectDidChange(actor, in: self)

        let wasWithinScene = actor.isWithinScene
        let sceneRect = Rect(origin: .zero, size: size)
        actor.isWithinScene = actor.rect.intersects(sceneRect)
        
        if !wasWithinScene && actor.isWithinScene {
            actor.events.enteredScene.trigger()
        } else if wasWithinScene && !actor.isWithinScene {
            actor.events.leftScene.trigger()
        }
    }

    internal func blockRectDidChange(_ block: Block) {
        grid.blockRectDidChange(block)
    }

    // MARK: - Private

    private func pauseStatusDidChange() {
        timeline.isPaused = isPaused
    }

    private func sizeDidChange() {
        layer.bounds.size = size
        camera.sceneSize = size
    }

    private func safeAreaInsetsDidChange(from oldValue: EdgeInsets) {
        guard safeAreaInsets != oldValue else {
            return
        }

        events.safeAreaInsetsChanged.trigger()
    }

    private func backgroundColorDidChange() {
        layer.backgroundColor = backgroundColor.cgColor
    }

    private func deactivate(_ object: SceneObject) {
        guard object.scene === self else {
            return
        }

        object.scene = nil
        object.deactivate()
    }
}

public extension Scene {
    /// The center point of the scene (within its own coordinate system)
    var center: Point {
        return Point(x: size.width / 2, y: size.height / 2)
    }
}
