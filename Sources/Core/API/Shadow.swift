/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Structure used to describe a shadow that should be rendered for an object
public struct Shadow {
    /// The radius of the shadow, that is, to what distance it should be blurred
    public var radius: Metric
    /// The opacity of the shadow (between 0 - 1)
    public var opacity: Metric
    /// The color of the shadow (default = .black)
    public var color: Color
    /// The offset of the shadow, based on the object's center point
    public var offset: Point
    /// Any path to draw the shadow using. Specifying this may improve performance.
    public var path: Path?

    /// Initialize an instance with a given set of values
    public init(radius: Metric,
                opacity: Metric,
                color: Color = .black,
                offset: Point = .zero,
                path: Path? = nil) {
        self.radius = radius
        self.opacity = opacity
        self.color = color
        self.offset = offset
        self.path = path
    }
}
