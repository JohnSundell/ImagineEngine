/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Action that can be used to scale a scalable game object
public final class ScaleAction<Object: Scalable>: MetricAction<Object> {
    /// Initialize an instance with a target scale & a duration
    public init(scale: Metric, duration: TimeInterval) {
        super.init(
            mode: .target(scale),
            duration: duration,
            getClosure: { $0.scale },
            setClosure: { $0.scale = $1 }
        )
    }

    /// Initialize an instance with a delta scale & a duration
    public init(delta: Metric, duration: TimeInterval) {
        super.init(
            mode: .delta(delta),
            duration: duration,
            getClosure: { $0.scale },
            setClosure: { $0.scale = $1 }
        )
    }
}
