/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif

internal final class ClickPlugin: Plugin {
    private var tapRecognizer: ClickGestureRecognizer?
    private weak var scene: Scene?

    func activate(for object: Scene, in game: Game) {
        scene = object

        let tapRecognizer = ClickGestureRecognizer(target: self, action: #selector(handleTapRecognizer))
        self.tapRecognizer = tapRecognizer
        game.view.addGestureRecognizer(tapRecognizer)
    }

    func deactivate() {
        scene = nil

        if let tapRecognizer = tapRecognizer {
            tapRecognizer.view?.removeGestureRecognizer(tapRecognizer)
        }
    }

    @objc private func handleTapRecognizer(_ recognizer: ClickGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)

        scene?.events.clicked.trigger(with: point)

        scene?.actors(at: point).forEach { actor in
            if actor.isClickable {
                actor.events.clicked.trigger()
            }
        }
    }
}
