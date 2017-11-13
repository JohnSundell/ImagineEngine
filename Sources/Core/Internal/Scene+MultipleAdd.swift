/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

extension Scene {

    public func add(_ actors: Actor...) {
        actors.forEach(add)
    }

    public func add(_ labels: Label...) {
        labels.forEach(add)
    }

    public func add(_ blocks: Block...) {
        blocks.forEach(add)
    }
}
