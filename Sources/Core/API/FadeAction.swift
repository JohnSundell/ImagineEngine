/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Action that can be used to fade objects that are fadable over time
public final class FadeAction<Object: Fadeable>: MetricAction<Object> {
    /// Initialize an instance with a target opacity & duration
    public init(opacity: Metric, duration: TimeInterval) {
        super.init(
            mode: .target(opacity),
            duration: duration,
            getClosure: { $0.opacity },
            setClosure: { $0.opacity = $1 }
        )
    }

    /// Initialize an instance with a delta opacity & duration
    public init(delta: Metric, duration: TimeInterval) {
        super.init(
            mode: .delta(delta),
            duration: duration,
            getClosure: { $0.opacity },
            setClosure: { $0.opacity = $1 }
        )
    }
}
