/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Protocol adopted by objects that have their hash value calculated
/// based on their instance (object) identifier
public protocol InstanceHashable: class, Hashable {}

extension InstanceHashable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    public var hashValue: Int {
        return ObjectIdentifier(self).hashValue
    }
}
