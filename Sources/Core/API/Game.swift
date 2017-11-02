/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class used to create an Imagine Engine game
 *
 *  A Game is the root object any Imagine Engine game and provides a view
 *  that can be attached to an app's view hierarchy. To present game content
 *  create a `Scene` and attach it to your game.
 */
open class Game {
    /// The game's view, attach it to one of your app's views to start the game
    public let view: View
    /// The current active scene that the game is presenting
    public var scene: Scene { didSet { sceneDidChange(from: oldValue) } }

    internal private(set) var currentTime: TimeInterval

    private let displayLink: DisplayLinkProtocol
    private let dateProvider: () -> Date
    private var isActive = false

    // MARK: - Initializers

    /// Initialize an instance with a certain viewport size & an initial scene
    public convenience init(size: Size, scene: Scene) {
        let view = GameView(frame: Rect(origin: .zero, size: size))
        self.init(view: view, scene: scene, displayLink: DisplayLink())
    }

    internal init(view: GameView, scene: Scene, displayLink: DisplayLinkProtocol, dateProvider: @escaping () -> Date = Date.init) {
        self.view = view
        self.scene = scene
        self.displayLink = displayLink
        self.dateProvider = dateProvider
        currentTime = dateProvider().timeIntervalSinceReferenceDate

        view.game = self
        sceneDidChange(from: nil)
    }

    // MARK: - Internal

    internal func updateActivationStatus() {
        guard view.superview != nil else {
            isActive = false
            return
        }

        guard view.frame.size != .zero else {
            isActive = false
            return
        }

        guard !isActive else {
            return
        }

        isActive = true
        scene.activate(in: self)
        displayLink.activate()
    }

    // MARK: - Private
    
    private func sceneDidChange(from previousScene: Scene?) {
        previousScene?.deactivate()

        if isActive {
            scene.activate(in: self)
        }

        displayLink.callback = { [weak self] in
            guard let `self` = self else {
                return
            }

            self.currentTime = self.dateProvider().timeIntervalSinceReferenceDate
            self.scene.timeline.update(currentTime: self.currentTime)
        }
    }
}
