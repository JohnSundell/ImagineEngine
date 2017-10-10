/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Protocol adopted by objects that can be rotated
public protocol Rotatable: class {
    /// The rotation of the object along the Z-axis (in radians)
    var rotation: Metric { get set }
}

public extension Rotatable where Self: ActionPerformer {
    /// Rotate the object by a certain amount of radians over a time interval
    @discardableResult func rotate(by delta: Metric, duration: TimeInterval) -> ActionToken {
        return perform(RotateAction(delta: delta, duration: duration))
    }
}
