/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Object representing an action that can be performed by an Imagine Engine game object
 *
 *  By making an Actor or Camera perform an action, by can change one of its properties
 *  over time. Actions have a set duration during which they are performed, and get updated
 *  every frame. You can use actions to, for example, move objects around, resize them
 *  or fade them in or out.
 *
 *  Imagine Engine ships with a default set of actions that are ready to use, and you
 *  can also easily define your own by subclassing this class and overriding one of the
 *  override points to perform your own custom action logic.
 *
 *  Here's an example of how an Action can be used to move an Actor:
 *
 *  ```
 *  let point = Point(x: 200, y: 300)
 *  actor.perform(MoveAction(destination: point, duration: 5))
 *  ```
 *
 *  When actions are performed, you get an `ActionToken` back as the result. These tokens
 *  enable you to both cancel an ongoing action, as well as to observe when it has been
 *  completed and chain it to other actions.
 */
open class Action<Object> {
    internal let duration: TimeInterval
    internal let token = ActionToken()

    private var startTime: TimeInterval?
    private var lastUpdateTime: TimeInterval?

    // MARK: - Initializer

    /// Initialize an instance of this class with a duration
    public init(duration: TimeInterval) {
        self.duration = duration
    }

    // MARK: - Override points

    /// Called on your action whenever it was started for an object
    open func start(for object: Object) {}

    /// Called on each frame for as long as the action is active, with a context object
    /// that can be used to drive your action's logic
    open func update(with context: UpdateContext) {}

    /// Called whenever the action was cancelled, with the object it was attached to
    open func cancel(for object: Object) {}

    /// Called whenever the action finished, with the object it was attached to
    open func finish(for object: Object) {}

    // MARK: - Internal

    internal func reset() {
        startTime = nil
        lastUpdateTime = nil
    }

    internal func update(for object: Object, currentTime: TimeInterval) -> UpdateOutcome {
        let startTime = self.startTime.get(orSet: currentTime)
        let timeElapsed = currentTime - startTime
        let completionRatio = min(Metric(timeElapsed) / Metric(duration), 1)
        let timeSinceLastUpdate = currentTime - (lastUpdateTime ?? currentTime)

        let context = Action.UpdateContext(
            object: object,
            timeElapsed: timeElapsed,
            timeSinceLastUpdate: timeSinceLastUpdate,
            completionRatio: completionRatio
        )

        update(with: context)
        lastUpdateTime = currentTime

        if context.completionRatio < 1 {
            return .continueAfter(0)
        }

        return .finished
    }
}

public extension Action {
    struct UpdateContext {
        public let object: Object
        public let timeElapsed: TimeInterval
        public let timeSinceLastUpdate: TimeInterval
        public let completionRatio: Metric
    }
}
