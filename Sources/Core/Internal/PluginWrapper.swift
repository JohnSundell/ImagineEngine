/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class PluginWrapper: Activatable {
    private let activateClosure: (Game) -> Void
    private let deactivateClosure: () -> Void

    // MARK: - Initializer

    init<P: Plugin>(plugin: P, object: P.Object) {
        activateClosure = { [weak object] game in
            if let object = object {
                plugin.activate(for: object, in: game)
            }
        }
        deactivateClosure = plugin.deactivate
    }

    // MARK: - Activatable

    func activate(in game: Game) {
        activateClosure(game)
    }

    func deactivate() {
        deactivateClosure()
    }
}
