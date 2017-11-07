/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// An action that repeats another action until it's cancelled
public final class RepeatAction<Object: AnyObject>: Action<Object> {
    private let action: Action<Object>
    private var actionWrapper: ActionWrapper<Object>?

    /// Initialize an instance with an action to repeat
    public init(action: Action<Object>) {
        self.action = action
        super.init(duration: action.duration)
    }

    internal override func update(for object: Object, currentTime: TimeInterval) -> UpdateOutcome {
        let wrapper = actionWrapper.get(orSet: ActionWrapper(action: action, object: object))
        _ = wrapper.update(currentTime: currentTime)
        return .continueAfter(0)
    }
}

public extension ActionPerformer {
    /// Repeat an action until its cancelled using the returned token
    func `repeat`(_ action: Action<Self>) -> ActionToken {
        return perform(RepeatAction(action: action))
    }
}
