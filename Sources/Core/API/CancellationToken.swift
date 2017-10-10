/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class used to cancel an operation that takes place over time
 *
 *  Whenever you perform an action, schedule an event on a timeline
 *  or do something else that will either be performed later or
 *  during a longer period of time, Imagine Engine returns a token
 *  to you that can be used to cancel that operation.
 */
public class CancellationToken: InstanceHashable {
    internal private(set) var isCancelled = false

    /// Cancel the operation that this token is for
    public func cancel() {
        isCancelled = true
    }
}
