/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Cocoa

extension EdgeInsets: Equatable {
    public static func ==(lhs: EdgeInsets, rhs: EdgeInsets) -> Bool {
        // swiftlint:disable:next legacy_nsgeometry_functions
        return NSEdgeInsetsEqual(lhs, rhs)
    }
}
