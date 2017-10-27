/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class UpdatableWrapper: Updatable {
    let cancellationToken = CancellationToken()
    fileprivate let updatable: Updatable

    init(updatable: Updatable) {
        self.updatable = updatable
    }

    // MARK: - Updatable

    func update(currentTime: TimeInterval) -> UpdateOutcome {
        guard !cancellationToken.isCancelled else {
            return .finished
        }

        return updatable.update(currentTime: currentTime)
    }
}
