/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Protocol adopted by objects that can have their opacity changed
public protocol Fadeable: class {
    /// The opacity of the object, ranging from 0 (invisible) - 1 (opaque)
    var opacity: Metric { get set }
}

public extension Fadeable where Self: ActionPerformer {
    /// Fade in the object (to opacity = 1) with a given duration
    @discardableResult func fadeIn(withDuration duration: TimeInterval) -> ActionToken {
        return perform(FadeAction(opacity: 1, duration: duration))
    }

    /// Fade the object to a given opacity with a duration
    @discardableResult func fade(to opacity: Metric, withDuration duration: TimeInterval) -> ActionToken {
        return perform(FadeAction(opacity: opacity, duration: duration))
    }

    /// Fade out the object (to opacity = 0) with a given duration
    @discardableResult func fadeOut(withDuration duration: TimeInterval) -> ActionToken {
        return perform(FadeAction(opacity: 0, duration: duration))
    }
}
