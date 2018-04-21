/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Enum defining various constraints that can be applied to Imagine Engine
/// game objects, in order to restrict their movement in various ways.
public enum Constraint: Hashable {
    /// Constraint the object to its scene. When this constraint it set the
    /// object won't be able to leave its scene.
    case scene
    /// Prevent the object from overlaping a block in a given group.
    case neverOverlapBlockInGroup(Group)
}
