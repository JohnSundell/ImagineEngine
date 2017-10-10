/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class ActionManager<Object: AnyObject>: Activatable {
    private lazy var queue = [ActionWrapper<Object>]()
    private weak var scene: Scene?
    private weak var object: Object?

    // MARK: - Initializer

    init(object: Object) {
        self.object = object
    }

    // MARK: - API

    func add(_ action: Action<Object>) -> ActionToken {
        guard let object = object else {
            return ActionToken()
        }

        let wrapper = ActionWrapper(action: action, object: object)

        if let scene = scene {
            scene.requestUpdate(for: wrapper)
        } else {
            queue.append(wrapper)
        }

        return action.token
    }

    // MARK: - Activatable

    func activate(in game: Game) {
        scene = game.scene

        let actions = queue
        queue = []
        actions.forEach(game.scene.requestUpdate)
    }

    func deactivate() {
        scene = nil
    }
}
