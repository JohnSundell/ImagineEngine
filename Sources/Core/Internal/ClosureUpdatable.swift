/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class ClosureUpdatable: Updatable {
    private let closure: () -> Void
    private let repeatInterval: TimeInterval?

    init(closure: @escaping () -> Void, repeatInterval: TimeInterval?) {
        self.closure = closure
        self.repeatInterval = repeatInterval
    }

    func update(currentTime: TimeInterval) -> UpdateOutcome {
        closure()

        guard let repeatInterval = repeatInterval else {
            return .finished
        }

        return .continueAfter(repeatInterval)
    }
}
