/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal protocol Updatable: class {
    func update(currentTime: TimeInterval) -> UpdateOutcome
}
