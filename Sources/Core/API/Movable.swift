/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Protocol adopted by objects that can have their position changed
public protocol Movable: class {
    /// The current position of the object within its scene
    var position: Point { get set }
}

public extension Movable {
    /// Move the object by certain distances on the x & y axis
    func move(byX x: Metric, y: Metric = 0) {
        position.x += x
        position.y += y
    }

    /// Move the object by a certain distance on the y axis
    func move(byY y: Metric) {
        position.y += y
    }
}

public extension Movable where Self: ActionPerformer {
    /// Move the object to a given point over a time interval
    @discardableResult func move(to point: Point, duration: TimeInterval) -> ActionToken {
        return perform(MoveAction(destination: point, duration: duration))
    }

    /// Move the object to given X & Y coordinates over a time interval
    @discardableResult func move(toX x: Metric, y: Metric, duration: TimeInterval) -> ActionToken {
        return move(to: Point(x: x, y: y), duration: duration)
    }

    /// Move the object by a given distance on the X/Y axis, over a time interval
    @discardableResult func move(byX x: Metric, y: Metric, duration: TimeInterval) -> ActionToken {
        return move(by: Vector(dx: x, dy: y), duration: duration)
    }

    /// Move the object by a vector over a time interval
    @discardableResult func move(by vector: Vector, duration: TimeInterval) -> ActionToken {
        return perform(MoveAction(vector: vector, duration: duration))
    }
}
