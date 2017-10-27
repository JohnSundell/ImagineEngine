/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class ClickPlugin: Plugin {
    private let gestureRecognizer: ClickGestureRecognizer
    private weak var scene: Scene?

    // MARK: - Initializer

    init(gestureRecognizer: ClickGestureRecognizer = .init()) {
        self.gestureRecognizer = gestureRecognizer
        gestureRecognizer.addTarget(self, action: #selector(handleGestureRecognizer))
    }

    // MARK: - Plugin

    func activate(for object: Scene, in game: Game) {
        scene = object
        game.view.addGestureRecognizer(gestureRecognizer)
    }

    func deactivate() {
        scene = nil
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }

    // MARK: - API

    func trigger() {
        handleGestureRecognizer(gestureRecognizer)
    }

    // MARK: - Private

    @objc private func handleGestureRecognizer(_ recognizer: ClickGestureRecognizer) {
        guard let scene = scene else {
            return
        }

        var point = recognizer.location(in: recognizer.view)

        #if os(macOS)
        point.y = scene.camera.size.height - point.y
        #endif

        point.x += scene.camera.rect.minX
        point.y += scene.camera.rect.minY

        scene.events.clicked.trigger(with: point)

        scene.actors(at: point).forEach { actor in
            if actor.isClickable {
                actor.events.clicked.trigger()
            }
        }
    }
}
