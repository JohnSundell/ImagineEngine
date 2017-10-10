/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class that can be used to implement custom actions using a closure
 *
 *  This class provides a simple way to define your own custom actions,
 *  by simply using a closure that gets passed the current update context
 *  whenever the action is updated.
 */
public final class ClosureAction<Object>: Action<Object> {
    private let closure: (UpdateContext) -> Void

    /// Initialize an instance with a given duration and a closure that will
    /// be run on every update of the action.
    public init(duration: TimeInterval, closure: @escaping (UpdateContext) -> Void) {
        self.closure = closure
        super.init(duration: duration)
    }

    public override func update(with context: UpdateContext) {
        closure(context)
    }
}
