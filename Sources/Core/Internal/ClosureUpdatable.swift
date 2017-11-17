/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class ClosureUpdatable: Updatable {
    private let closure: () -> UpdateOutcome

    // MARK: - Initializers

    init(closure: @escaping () -> Void) {
        self.closure = {
            closure()
            return .finished
        }
    }

    init(repeatMode: RepeatMode, closure: @escaping () -> UpdateOutcome) {
        var repeatMode = repeatMode

        self.closure = {
            switch repeatMode {
            case .forever:
                break
            case .times(let count):
                guard count > 0 else {
                    return .finished
                }

                repeatMode = .times(count - 1)
            }

            return closure()
        }
    }

    // MARK: - Updatable

    func update(currentTime: TimeInterval) -> UpdateOutcome {
        return closure()
    }
}
