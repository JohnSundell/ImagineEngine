/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal extension Optional {
    mutating func get(orSet valueClosure: @autoclosure () -> Wrapped) -> Wrapped {
        if let value = self {
            return value
        }

        let value = valueClosure()
        self = .some(value)
        return value
    }
}
