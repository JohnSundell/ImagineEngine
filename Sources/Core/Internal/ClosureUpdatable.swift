/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class ClosureUpdatable: Updatable {
    private let closure: () -> UpdateOutcome

    init(closure: @escaping () -> Void) {
        self.closure = {
            closure()
            return .finished
        }
    }

    init(closure: @escaping () -> UpdateOutcome) {
        self.closure = closure
    }

    func update(currentTime: TimeInterval) -> UpdateOutcome {
        return closure()
    }
}
