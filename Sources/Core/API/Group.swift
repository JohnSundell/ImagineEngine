/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Enum used to define logical groups that game objects can belong to
public enum Group {
    /// A group that is identified by a string-based name
    case name(String)
    /// A group that is identifier by a number
    case number(Int)
}

public extension Group {
    /// Create a group using a member of a string-based enum
    static func enumValue<R: RawRepresentable>(_ value: R) -> Group where R.RawValue == String {
        return .name(value.rawValue)
    }

    /// Create a group using a member of an int-based enum
    static func enumValue<R: RawRepresentable>(_ value: R) -> Group where R.RawValue == Int {
        return .number(value.rawValue)
    }
}

internal extension Group {
    var identifier: String {
        switch self {
        case .name(let name):
            return "name-\(name)"
        case .number(let number):
            return "number-\(number)"
        }
    }
}

extension Group: Hashable {
    public static func ==(lhs: Group, rhs: Group) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public var hashValue: Int {
        return identifier.hashValue
    }
}
