/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Base class for actions that change a metric over time
public class MetricAction<Object>: Action<Object> {
    private let mode: Mode
    private let getClosure: (Object) -> Metric
    private let setClosure: (Object, Metric) -> Void
    private var startMetric: Metric?

    // MARK: - Initializer

    internal init(mode: Mode,
                  duration: TimeInterval,
                  getClosure: @escaping (Object) -> Metric,
                  setClosure: @escaping (Object, Metric) -> Void) {
        self.mode = mode
        self.getClosure = getClosure
        self.setClosure = setClosure
        super.init(duration: duration)
    }

    // MARK: - Action

    public override func start(for object: Object) {
        startMetric = nil
    }

    public override func update(with context: Action<Object>.UpdateContext) {
        let startMetric = self.startMetric.get(orSet: getClosure(context.object))
        let delta = calculateDelta(from: startMetric)
        setClosure(context.object, startMetric + delta * context.completionRatio)
    }

    // MARK: - Private

    private func calculateDelta(from startMetric: Metric) -> Metric {
        switch mode {
        case .target(let target):
            return target - startMetric
        case .delta(let delta):
            return delta
        }
    }
}

internal extension MetricAction {
    enum Mode {
        case target(Metric)
        case delta(Metric)
    }
}
