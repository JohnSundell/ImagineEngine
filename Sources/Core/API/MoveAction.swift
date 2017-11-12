/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Action used to move an object over a certain period of time
public final class MoveAction<Object: Movable>: Action<Object> {
    private let mode: Mode
    private var vector: Vector?
    private var previousCompletionRatio: Metric?

    /// Initialize an instance with a destination to move to & a duration
    public init(destination: Point, duration: TimeInterval) {
        self.mode = .destination(destination)
        super.init(duration: duration)
    }

    /// Initialize an instance with a vector to move by & a duration
    public init(vector: Vector, duration: TimeInterval) {
        self.mode = .vector(vector)
        super.init(duration: duration)
    }

    public override func start(for object: Object) {
        vector = nil
        previousCompletionRatio = nil
    }

    public override func update(with context: UpdateContext) {
        let completionRatioDelta = context.completionRatio - (previousCompletionRatio ?? 0)
        let vector = self.vector.get(orSet: calculateVector(from: context.object.position))

        context.object.position = Point(
            x: context.object.position.x + vector.dx * completionRatioDelta,
            y: context.object.position.y + vector.dy * completionRatioDelta
        )

        previousCompletionRatio = context.completionRatio
    }

    private func calculateVector(from startPosition: Point) -> Vector {
        switch mode {
        case .destination(let destination):
            return Vector(
                dx: destination.x - startPosition.x,
                dy: destination.y - startPosition.y
            )
        case .vector(let vector):
            return vector
        }
    }
}

private extension MoveAction {
    enum Mode {
        case destination(Point)
        case vector(Vector)
    }
}
