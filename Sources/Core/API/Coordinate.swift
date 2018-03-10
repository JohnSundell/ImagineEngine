/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2018
 *  See LICENSE file for license
 */

import Foundation

/// Type that can be used to express a non-fractional coordinate within a space
/// In Imagine Engine itself this is mostly used to slice sprite sheets, but you
/// can also use it in your own code for maps and other coordinate systems.
///
/// Note on comparability: A coordinate is considered to be "lower than" another
/// when either its x or y component has a lower value than the other coordinate.
public struct Coordinate {
    /// The coordinate's position on the horizontal axis
    public var x: Int
    /// The coordinate's position on the vertical axis
    public var y: Int

    /// Initialize an instance with given x & y values
    public init(x: Int = 0, y: Int = 0) {
        self.x = x
        self.y = y
    }
}

extension Coordinate: Comparable {
    public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }

    public static func <(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x < rhs.x || lhs.y < rhs.y
    }
}

public extension Coordinate {
    /// A coordinate value that has both its x & y components set to 0
    static var zero: Coordinate {
        return Coordinate()
    }
}
