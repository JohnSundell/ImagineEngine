/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Action that can be used to rotate a game object
public final class RotateAction<Object: Rotatable>: MetricAction<Object> {
    /// Initialize an instance with a target rotation & a duration
    public init(rotation: Metric, duration: TimeInterval) {
        super.init(
            mode: .target(rotation),
            duration: duration,
            getClosure: { $0.rotation },
            setClosure: { $0.rotation = $1 }
        )
    }

    /// Initialize an instance with a delta rotation & a duration
    public init(delta: Metric, duration: TimeInterval) {
        super.init(
            mode: .delta(delta),
            duration: duration,
            getClosure: { $0.rotation },
            setClosure: { $0.rotation = $1 }
        )
    }
}
