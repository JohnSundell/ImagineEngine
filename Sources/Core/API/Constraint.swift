/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Enum defining various constraints that can be applied to Imagine Engine
/// game objects, in order to restrict their movement in various ways.
public enum Constraint {
    /// Constraint the object to its scene. When this constraint it set the
    /// object won't be able to leave its scene.
    case scene
    /// Prevent the object from overlaping a block in a given group.
    case neverOverlapBlockInGroup(Group)
}

extension Constraint: Hashable {
    public static func ==(lhs: Constraint, rhs: Constraint) -> Bool {
        switch (lhs, rhs) {
        case (.scene, .scene):
            return true
        case (.neverOverlapBlockInGroup(let groupA), .neverOverlapBlockInGroup(let groupB)):
            return groupA == groupB
        case (.scene, .neverOverlapBlockInGroup):
            return false
        case (.neverOverlapBlockInGroup, .scene):
            return false
        }
    }

    public var hashValue: Int {
        switch self {
        case .scene:
            return 0
        case .neverOverlapBlockInGroup(let group):
            return 1 + group.hashValue
        }
    }
}
