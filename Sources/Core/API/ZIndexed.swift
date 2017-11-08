/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Protocol adopted by types that can be indexed along the z axis
public protocol ZIndexed: class {
    /// The index of the object on the z axis. 0 = implicit index.
    var zIndex: Int { get set }
}
