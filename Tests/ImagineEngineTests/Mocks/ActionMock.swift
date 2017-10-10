/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import ImagineEngine

final class ActionMock<Object: AnyObject>: Action<Object> {
    private(set) weak var object: Object?
    private(set) var context: UpdateContext?
    private(set) var isStarted = false
    private(set) var isCancelled = false
    private(set) var isFinished = false

    override func start(for object: Object) {
        self.object = object
        isStarted = true
    }

    override func update(with context: UpdateContext) {
        self.context = context
    }

    override func cancel(for object: Object) {
        isCancelled = true
    }

    override func finish(for object: Object) {
        isFinished = true
    }
}
