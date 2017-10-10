/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Protocol adopted by objects that are able to perform actions
 *
 *  You don't conform to this protocol yourself, instead `Actor` & `Camera` already
 *  conform to this protocol, making them ready to perform actions.
 */
public protocol ActionPerformer: class {
    /// Perform an action
    /// The action will be started on the next frame, the returned `ActionToken`
    /// can be used to cancel the action, or chain it to other ones.
    @discardableResult func perform(_ action: Action<Self>) -> ActionToken
}
