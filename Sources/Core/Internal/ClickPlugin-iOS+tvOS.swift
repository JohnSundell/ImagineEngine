/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import UIKit

internal final class ClickPlugin: Plugin {
    private var tapRecognizer: UITapGestureRecognizer?
    private weak var scene: Scene?

    func activate(for object: Scene, in game: Game) {
        scene = object

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapRecognizer))
        self.tapRecognizer = tapRecognizer
        game.view.addGestureRecognizer(tapRecognizer)
    }

    func deactivate() {
        scene = nil

        if let tapRecognizer = tapRecognizer {
            tapRecognizer.view?.removeGestureRecognizer(tapRecognizer)
        }
    }

    @objc private func handleTapRecognizer(_ recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)

        scene?.events.clicked.trigger(with: point)

        scene?.actors(at: point).forEach { actor in
            if actor.isClickable {
                actor.events.clicked.trigger()
            }
        }
    }
}
