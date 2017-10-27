/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal struct UpdatableCollection {
    var isEmpty: Bool { return objects.isEmpty }

    private var identifiers = Set<ObjectIdentifier>()
    private var objects = [UpdatableWrapper]()

    mutating func insert(_ object: UpdatableWrapper) {
        let identifier = ObjectIdentifier(object)

        guard identifiers.insert(identifier).inserted else {
            return
        }

        objects.append(object)
    }

    mutating func removeAll() -> [UpdatableWrapper] {
        let allObjects = objects
        objects = []
        identifiers = []
        return allObjects
    }
}
