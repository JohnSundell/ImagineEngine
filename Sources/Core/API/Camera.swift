/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class that represents a camera in a scene
 *
 *  You use a scene's camera to move the viewport of your game around. Initially
 *  all cameras start out at the center of their scene. A camera gets its size
 *  from the game that its scene is presented in.
 */
public final class Camera: ActionPerformer, Pluggable, Movable, Activatable {
    /// The position of the camera within its scene
    public var position = Point() { didSet { positionDidChange(from: oldValue) } }
    /// The size of the camera's viewport. Set as soon as its presented in a game.
    public internal(set) var size = Size() { didSet { sizeDidChange(from: oldValue) }}
    /// The current rectangle of the camera's viewport.
    public private(set) var rect = Rect()
    /// A collection of events that can be used to observe the camera.
    public private(set) lazy var events = CameraEventCollection(object: self)
    /// Whether the camera is constrained to the scene or can move outside of it (default = false)
    public var constrainedToScene = false { didSet { update() } }

    private let pluginManager = PluginManager()
    private lazy var actionManager = ActionManager(object: self)
    private weak var scene: Scene?
    private let layer: Layer

    // MARK: - Initializer

    internal init(scene: Scene, layer: Layer) {
        self.scene = scene
        self.layer = layer

        scene.events.resized.addObserver(self) { camera in
            camera.update()
        }
    }

    // MARK: - ActionPerformer

    @discardableResult public func perform(_ action: Action<Camera>) -> ActionToken {
        return actionManager.add(action)
    }

    // MARK: - Pluggable

    @discardableResult public func add<P: Plugin>(_ plugin: @autoclosure () -> P,
                                                  reuseExistingOfSameType: Bool) -> P where P.Object == Camera {
        return pluginManager.add(plugin, for: self, reuseExistingOfSameType: reuseExistingOfSameType)
    }

    public func plugins<P: Plugin>(ofType type: P.Type) -> [P] where P.Object == Camera {
        return pluginManager.plugins(ofType: type)
    }

    public func remove<P: Plugin>(_ plugin: P) where P.Object == Camera {
        pluginManager.remove(plugin, from: self)
    }

    public func removePlugins<P: Plugin>(ofType type: P.Type) where P.Object == Camera {
        pluginManager.removePlugins(ofType: type, from: self)
    }

    // MARK: - Activatable

    internal func activate(in game: Game) {
        size = game.view.frame.size
        pluginManager.activate(in: game)
        actionManager.activate(in: game)
    }

    internal func deactivate() {
        pluginManager.deactivate()
        actionManager.deactivate()
    }

    // MARK: - Internal

    internal func handleClick(at point: Point) {
        events.clicked.trigger(with: point)
    }

    // MARK: - Private

    private func positionDidChange(from oldValue: Point) {
        if position != oldValue {
            update()
            events.moved.trigger(with: (oldValue, position))
        }
    }

    private func sizeDidChange(from oldValue: Size) {
        if size != oldValue {
            update()
            events.resized.trigger()
        }
    }

    private func update() {
        guard let scene = scene else {
            return
        }

        var newRect = Rect(origin: position, size: size)
        newRect.origin.x -= size.width / 2
        newRect.origin.y -= size.height / 2
        rect = newRect

        if constrainedToScene {
            if scene.size.width >= size.width {
                guard newRect.minX >= 0 else {
                    position.x = size.width / 2
                    return
                }

                guard newRect.maxX <= scene.size.width else {
                    position.x = scene.size.width - size.width / 2
                    return
                }
            }

            if scene.size.height >= size.height {
                guard newRect.minY >= 0 else {
                    position.y = size.height / 2
                    return
                }

                guard newRect.maxY <= scene.size.height else {
                    position.y = scene.size.height - size.height / 2
                    return
                }
            }
        }

        layer.frame.origin = Point(
            x: size.width / 2 - position.x,
            y: size.height / 2 - position.y
        )
    }
}
