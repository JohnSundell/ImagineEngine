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
public final class Camera: ActionPerformer, Movable, Activatable {
    /// The position of the camera within its scene
    public var position = Point() { didSet { update() } }
    /// The size of the camera's viewport. Set as soon as its presented in a game.
    public internal(set) var size = Size() { didSet { update() }}
    /// The current rectangle of the camera's viewport.
    public private(set) var rect = Rect()

    private let pluginManager = PluginManager()
    private lazy var actionManager = ActionManager(object: self)
    private let layer: Layer

    // MARK: - Initializer

    internal init(layer: Layer) {
        self.layer = layer
    }

    // MARK: - Plugin API

    public func add<P: Plugin>(_ plugin: @autoclosure () -> P) where P.Object == Camera {
        pluginManager.add(plugin, for: self)
    }

    public func remove<P: Plugin>(_ plugin: P) where P.Object == Camera {
        pluginManager.remove(plugin, from: self)
    }

    // MARK: - ActionPerformer

    @discardableResult public func perform(_ action: Action<Camera>) -> ActionToken {
        return actionManager.add(action)
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

    // MARK: - Private

    private func update() {
        layer.frame.origin = Point(
            x: size.width / 2 - position.x,
            y: size.height / 2 - position.y
        )

        var newRect = Rect(origin: position, size: size)
        newRect.origin.x -= size.width / 2
        newRect.origin.y -= size.height / 2
        rect = newRect
    }
}
