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

        let cameraPoint = recognizer.location(in: scene.camera)
        scene.camera.handleClick(at: cameraPoint)

        let scenePoint = scene.convertCameraPoint(cameraPoint)
        scene.handleClick(at: scenePoint)
    }
}

private extension ClickGestureRecognizer {
    func location(in camera: Camera) -> Point {
        var point = location(in: view)

        #if os(macOS)
        point.y = camera.size.height - point.y
        #endif

        return point
    }
}

private extension Scene {
    func convertCameraPoint(_ point: Point) -> Point {
        var point = point
        point.x += camera.rect.minX
        point.y += camera.rect.minY
        return point
    }
}
