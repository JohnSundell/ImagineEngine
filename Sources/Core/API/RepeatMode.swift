/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Enum used to express how many times a certain action should be repeated
public enum RepeatMode {
    /// Repeat the action a certain number of times
    case times(Int)
    /// Repeat the action forever (or until cancelled)
    case forever
}

public extension RepeatMode {
    /// Never repeat the action
    static var never: RepeatMode {
        return .times(0)
    }

    /// Repeat the action once
    static var once: RepeatMode {
        return .times(1)
    }
}

extension RepeatMode: Equatable {
    public static func ==(lhs: RepeatMode, rhs: RepeatMode) -> Bool {
        switch lhs {
        case .times(let lhsCount):
            switch rhs {
            case .times(let rhsCount):
                return lhsCount == rhsCount
            case .forever:
                return false
            }
        case .forever:
            switch rhs {
            case .forever:
                return true
            case .times:
                return false
            }
        }
    }
}
