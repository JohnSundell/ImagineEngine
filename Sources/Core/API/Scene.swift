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
    public private(set) lazy var camera = Camera(scene: self, layer: layer)
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
    public var size: Size { didSet { sizeDidChange(from: oldValue) } }
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

        camera.position = Point(x: size.width / 2, y: size.height / 2)
        layer.isOpaque = true

        sizeDidChange(from: .zero)
        backgroundColorDidChange()
        setup()

        add(ClickPlugin())
    }

    // MARK: - Override points

    /// Called when the scene was created or after it was reset.
    /// Put your code that sets up the scene in its initial state here.
    open func setup() {}

    /// Called when the scene was activated and will start running.
    /// Put your code that starts your game here.
    open func activate() {}

    // MARK: - API

    /// Reset the scene
    /// Calling this will remove all game objects from the scene, and
    /// reset it to its initial state. Once the reset has been completed,
    /// the `setup()` and `activate()` methods will be called.
    public func reset() {
        grid.deactivate()
        grid.removeAllObjects()
        pluginManager.deactivate()

        camera = Camera(scene: self, layer: layer)
        camera.position = Point(x: size.width / 2, y: size.height / 2)

        events = SceneEventCollection(object: self)
        grid = Grid()
        timeline = Timeline()

        game.map(timeline.activate)
        game.map(camera.activate)
        game.map(pluginManager.activate)
        game.map(grid.activate)

        setup()
        activate()
    }

    /// Add an actor to the scene
    public func add(_ actor: Actor) {
        grid.add(actor, in: self)
        layer.addSublayer(actor.layer)
        events.actorAdded.trigger(with: actor)
    }

    /// Add a block to the scene
    public func add(_ block: Block) {
        grid.add(block, in: self)
        layer.addSublayer(block.layer)
    }

    /// Add a label to the scene
    public func add(_ label: Label) {
        grid.add(label, in: self)
        layer.addSublayer(label.layer)
    }

    /// Get all actors which rects intersect a given point
    public func actors(at point: Point) -> [Actor] {
        return grid.actors(at: point)
    }

    /// Get all the labels which rects intersect a given point
    public func labels(at point: Point) -> [Label] {
        return grid.labels(at: point)
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
        grid.activate(in: game)

        activate()
    }

    internal func deactivate() {
        layer.removeFromSuperlayer()

        camera.deactivate()
        timeline.deactivate()
        pluginManager.deactivate()
        grid.deactivate()
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

    internal func remove(_ actor: Actor) {
        grid.remove(actor)
        events.actorRemoved.trigger(with: actor)
    }

    internal func remove(_ block: Block) {
        grid.remove(block)
    }

    internal func remove(_ label: Label) {
        grid.remove(label)
    }

    internal func blockRectDidChange(_ block: Block) {
        grid.blockRectDidChange(block)
    }

    internal func labelRectDidChange(_ label: Label) {
        grid.labelRectDidChange(label)
    }

    internal func handleClick(at point: Point) {
        events.clicked.trigger(with: point)
        grid.handleClick(at: point)
    }

    // MARK: - Private

    private func pauseStatusDidChange() {
        timeline.isPaused = isPaused
    }

    private func sizeDidChange(from oldValue: Size) {
        guard size != oldValue else {
            return
        }

        layer.bounds.size = size
        events.resized.trigger()
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
}

public extension Scene {
    /// The center point of the scene (within its own coordinate system)
    var center: Point {
        return Point(x: size.width / 2, y: size.height / 2)
    }

    func add(_ actors: Actor...) {
        actors.forEach(add)
    }

    func add(_ labels: Label...) {
        labels.forEach(add)
    }

    func add(_ blocks: Block...) {
        blocks.forEach(add)
    }
}
