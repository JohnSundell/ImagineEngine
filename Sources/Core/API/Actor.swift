/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class used to define an actor in a scene
 *
 *  Actors are used to create active, animatable game objects that will make up
 *  all moving & controllable objects in your game.
 *
 *  This class cannot be subclassed, and is instead designed to be configured &
 *  customized using Imagine Engine's Event & Plugin systems. By accessing an
 *  actor's event collection through the `event` property, you can easily bind
 *  actions to events that occur to it. You can also attach plugins to inject
 *  your own logic into an actor. See `Plugin` for more information.
 *
 *  An example of adding an Actor that is playing an "Idle" animation to a Scene:
 *
 *  ```
 *  let actor = Actor()
 *  actor.animation = Animation(name: "Idle", frameCount: 4, frameDuration: 0.15)
 *  scene.add(actor)
 *  ```
 */
public final class Actor: SceneObject, InstanceHashable, ActionPerformer,
                          Pluggable, ZIndexed, Movable, Rotatable, Scalable, Fadeable {
    /// The scene that the actor currently belongs to.
    public internal(set) weak var scene: Scene? { didSet { sceneDidChange() } }
    /// A collection of events that can be used to observe the actor.
    public private(set) lazy var events = ActorEventCollection(object: self)
    /// The index of the actor on the z axis. Affects rendering & hit testing. 0 = implicit index.
    public var zIndex = 0 { didSet { layer.zPosition = Metric(zIndex) } }
    /// The position (center-point) of the actor within its scene.
    public var position = Point() { didSet { positionDidChange(from: oldValue) } }
    /// The size of the actor (centered on its position).
    public var size = Size() { didSet { sizeDidChange(from: oldValue) } }
    /// The rectangle the actor currently occupies within its scene.
    public private(set) var rect = Rect() { didSet { rectDidChange() } }
    /// The rotation of the actor along the z axis.
    public var rotation = Metric() { didSet { rotationDidChange(from: oldValue) } }
    /// The scale the actor gets rendered at. Affects collision detection unless a hitboxSize is set.
    public var scale: Metric = 1 { didSet { scaleDidChange(from: oldValue) } }
    /// The velocity of the actor. Used for continous directional movement.
    public var velocity = Vector() { didSet { velocityDidChange(from: oldValue) } }
    /// The opacity of the actor. Ranges from 0 (transparent) - 1 (opaque).
    public var opacity = Metric(1) { didSet { layer.opacity = Float(opacity) } }
    /// Any mirroring to apply when rendering the actor. See `Mirroring` for options.
    public var mirroring = Set<Mirroring>() { didSet { layer.mirroring = mirroring } }
    /// The actor's background color. Default is `.clear` (no background).
    public var backgroundColor = Color.clear { didSet { layer.backgroundColor = backgroundColor.cgColor } }
    /// Any shadow that should be rendered beneath the actor. Using shadows may impact performance.
    public var shadow: Shadow? { didSet { shadowDidChange() } }
    /// Any texture-based animation that the actor is playing. See `Animation` for more info.
    public var animation: Animation? { didSet { animationDidChange(from: oldValue) } }
    /// Any prefix that should be prepended to the names of all textures loaded for the actor
    public var textureNamePrefix: String?
    /// Any explicit size of the actor's hitbox (for collision detection). `nil` = the actor's `size`.
    public var hitboxSize: Size?
    /// Whether the actor is able to participate in collisions.
    public var isCollisionDetectionEnabled = true
    /// Whether the actor responds to hit testing.
    public var isHitTestingEnabled = true { didSet { hitTestingStatusDidChange(from: oldValue) } }
    /// Any constraints that are applied to the actor, to restrict how and where it can move.
    public var constraints = Set<Constraint>()
    /// Any logical group that the actor is a part of. Can be used for events & collisions.
    public var group: Group?

    internal let layer = Layer()
    internal lazy var actorsInContact = Set<Actor>()
    internal lazy var blocksInContact = Set<Block>()
    internal lazy var gridTiles = Set<Grid.Tile>()
    internal var isWithinScene = false
    internal var isCollisionDetectionActive = false

    private let pluginManager = PluginManager()
    private lazy var actionManager = ActionManager(object: self)
    private var velocityActionToken: ActionToken?
    private var animationActionToken: ActionToken?
    private var isUpdatingPosition = false

    // MARK: - Initializer

    /// Initialize an instance of this class
    public init() {}

    // MARK: - SceneObject

    internal func addLayer(to superlayer: Layer) {
        superlayer.addSublayer(layer)
    }

    internal func add(to gridTile: Grid.Tile) {
        gridTile.actors.insert(self)
        gridTiles.insert(gridTile)
    }

    internal func remove(from gridTile: Grid.Tile) {
        gridTile.actors.remove(self)
        gridTiles.remove(gridTile)

        for otherActor in gridTile.actors {
            guard otherActor.actorsInContact.remove(self) != nil else {
                continue
            }

            actorsInContact.remove(otherActor)
        }

        for block in gridTile.blocks {
            guard block.actorsInContact.remove(self) != nil else {
                continue
            }

            blocksInContact.remove(block)
        }
    }

    // MARK: - ActionPerformer

    @discardableResult public func perform(_ action: Action<Actor>) -> ActionToken {
        return actionManager.add(action)
    }

    // MARK: - Pluggable

    @discardableResult public func add<P: Plugin>(_ plugin: @autoclosure () -> P,
                                                  reuseExistingOfSameType: Bool) -> P where P.Object == Actor {
        return pluginManager.add(plugin, for: self, reuseExistingOfSameType: reuseExistingOfSameType)
    }

    public func plugins<P: Plugin>(ofType type: P.Type) -> [P] where P.Object == Actor {
        return pluginManager.plugins(ofType: type)
    }

    public func remove<P: Plugin>(_ plugin: P) where P.Object == Actor {
        pluginManager.remove(plugin, from: self)
    }

    public func removePlugins<P: Plugin>(ofType type: P.Type) where P.Object == Actor {
        pluginManager.removePlugins(ofType: type, from: self)
    }

    // MARK: - Activatable

    internal func activate(in game: Game) {
        pluginManager.activate(in: game)
        actionManager.activate(in: game)
    }

    internal func deactivate() {
        pluginManager.deactivate()
        actionManager.deactivate()
        layer.removeFromSuperlayer()
    }

    /// Remove this actor from its scene
    public func remove() {
        scene?.remove(self)
    }

    // MARK: - Internal

    internal func render(frame: Animation.Frame, scale: Int?, resize: Bool, ignoreNamePrefix: Bool) {
        guard let textureManager = scene?.textureManager else {
            return
        }

        let namePrefix = ignoreNamePrefix ? nil : textureNamePrefix
        let loadedTexture = textureManager.load(frame.texture, namePrefix: namePrefix, scale: scale)

        layer.contents = loadedTexture?.image
        layer.contentsRect = frame.contentRect

        if resize {
            if var newSize = loadedTexture?.size {
                newSize.width *= frame.contentRect.width
                newSize.height *= frame.contentRect.height
                size = newSize
            }
        }
    }

    // MARK: - Private

    private func sceneDidChange() {
        renderFirstAnimationFrameIfNeeded()
    }

    private func positionDidChange(from oldValue: Point) {
        guard position != oldValue else {
            return
        }

        let isOriginalUpdate = !isUpdatingPosition
        isUpdatingPosition = true
        updateRect()

        guard isOriginalUpdate else {
            return
        }

        isUpdatingPosition = false

        guard position != oldValue else {
            return
        }

        layer.position = position
        events.moved.trigger(with: (oldValue, position))
        events.rectChanged.trigger()
    }

    private func sizeDidChange(from oldValue: Size) {
        guard size != oldValue else {
            return
        }

        layer.bounds.size = size
        updateRect()

        events.resized.trigger()
        events.rectChanged.trigger()
    }

    private func rotationDidChange(from oldValue: Metric) {
        guard rotation != oldValue else {
            return
        }

        layer.rotation = rotation

        events.rotated.trigger()
    }

    private func rectDidChange() {
        guard isCollisionDetectionEnabled || isHitTestingEnabled else {
            return
        }

        scene?.actorRectDidChange(self)
    }

    private func scaleDidChange(from oldValue: Metric) {
        guard oldValue != scale else {
            return
        }

        layer.scale = scale
        updateRect()
    }

    private func velocityDidChange(from oldValue: Vector) {
        guard velocity != oldValue else {
            return
        }

        events.velocityChanged.trigger()
        velocityActionToken?.cancel()

        guard velocity != .zero else {
            return
        }

        velocityActionToken = perform(RepeatAction(
            action: MoveAction(vector: velocity, duration: 1)
        ))
    }

    private func shadowDidChange() {
        layer.shadowRadius = shadow?.radius ?? 0
        layer.shadowOpacity = Float(shadow?.opacity ?? 0)
        layer.shadowColor = shadow?.color.cgColor
        layer.shadowOffset.width = shadow?.offset.x ?? 0
        layer.shadowOffset.height = shadow?.offset.y ?? 0
        layer.shadowPath = shadow?.path
    }

    private func animationDidChange(from oldValue: Animation?) {
        guard animation != oldValue else {
            return
        }

        animationActionToken?.cancel()

        guard let animation = animation else {
            layer.contents = nil
            return
        }

        renderFirstAnimationFrameIfNeeded()

        guard animation.frameCount > 1 else {
            return
        }

        let action = AnimationAction(animation: animation, triggeredByActor: true)
        animationActionToken = perform(action)
    }

    private func hitTestingStatusDidChange(from oldValue: Bool) {
        if oldValue == false && isHitTestingEnabled == true {
            rectDidChange()
        }
    }

    private func updateRect() {
        var newRect = Rect(origin: position, size: size)
        newRect.size.width *= scale
        newRect.size.height *= scale
        newRect.origin.x -= newRect.width / 2
        newRect.origin.y -= newRect.height / 2
        rect = newRect
    }

    private func renderFirstAnimationFrameIfNeeded() {
        guard let animation = animation else {
            return
        }

        guard animation.frameCount > 0 else {
            return
        }

        render(frame: animation.frame(at: 0),
               scale: animation.textureScale,
               resize: animation.autoResize,
               ignoreNamePrefix: animation.ignoreTextureNamePrefix)
    }
}

public extension Actor {
    /// Initialize an actor that renders a single texture with a given name
    convenience init(textureNamed textureName: String, scale: Int? = nil, format: TextureFormat? = nil) {
        self.init()
        animation = Animation(textureNamed: textureName, scale: scale, format: format)
        animationDidChange(from: nil)
    }

    /// Initialize an actor that renders a single image as its animation
    convenience init(image: Image) {
        self.init()
        animation = Animation(image: image)
        animationDidChange(from: nil)
    }

    /// Initialize an actor with a given size
    convenience init(size: Size) {
        self.init()
        self.size = size
        sizeDidChange(from: .zero)
    }

    /// Makes the actor start playing an animation as an action
    func playAnimation(_ animation: Animation) -> ActionToken {
        return perform(AnimationAction(animation: animation))
    }
}

internal extension Actor {
    var rectForCollisionDetection: Rect {
        if let hitboxSize = hitboxSize {
            var rect = Rect(origin: position, size: hitboxSize)
            rect.origin.x -= hitboxSize.width / 2
            rect.origin.y -= hitboxSize.height / 2
            return rect
        }

        return rect
    }
}
