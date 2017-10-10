/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class ActionWrapper<Object: AnyObject>: Updatable {
    private let action: Action<Object>
    private weak var object: Object?
    private var isInProgress = false

    init(action: Action<Object>, object: Object) {
        self.action = action
        self.object = object
    }

    // MARK: - Updatable

    func update(currentTime: TimeInterval) -> UpdateOutcome {
        guard let object = object else {
            return .finished
        }

        if !isInProgress {
            isInProgress = true
            action.start(for: object)

            for linkedToken in action.token.linkedTokens {
                linkedToken.isPending = false
            }
        }

        guard !action.token.isCancelled else {
            action.cancel(for: object)
            reset()
            return .finished
        }

        guard !action.token.isPending else {
            return .continueAfter(0)
        }

        let outcome = action.update(for: object, currentTime: currentTime)

        switch outcome {
        case .continueAfter:
            break
        case .finished:
            action.finish(for: object)
            reset()
            action.token.performChaining()
        }

        return outcome
    }

    // MARK: - Private

    private func reset() {
        isInProgress = false
        action.reset()
    }
}
