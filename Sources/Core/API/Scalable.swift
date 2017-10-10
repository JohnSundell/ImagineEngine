/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Protocol adopted by objects that can be scaled
public protocol Scalable: class {
    /// The scale factor that is applied to the object. Affects rendering only.
    var scale: Metric { get set }
}

public extension Scalable where Self: ActionPerformer {
    /// Scale the object to a certain scale over a time interval
    @discardableResult func scale(to scale: Metric, duration: TimeInterval) -> ActionToken {
        return perform(ScaleAction(scale: scale, duration: duration))
    }

    /// Scale the object by a certain value over a time interval
    @discardableResult func scale(by delta: Metric, duration: TimeInterval) -> ActionToken {
        return perform(ScaleAction(delta: delta, duration: duration))
    }
}
