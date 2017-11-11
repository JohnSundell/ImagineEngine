/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import ImagineEngine

final class PluginMock<Object: AnyObject>: Plugin {
    private(set) weak var object: Object?
    private(set) weak var game: Game?
    private(set) var isActive = false
    private(set) var activationCount = 0
    private(set) var deactivationCount = 0

    func activate(for object: Object, in game: Game) {
        self.object = object
        self.game = game
        isActive = true
        activationCount += 1
    }

    func deactivate() {
        isActive = false
        deactivationCount += 1
    }
}
