/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

internal final class TextLayer: CATextLayer {

    var rotation: Metric = 0 { didSet { updateTransform() } }
    var scale: Metric = 1 { didSet { updateTransform() } }

    override func action(forKey event: String) -> CAAction? {
        return NSNull()
    }

    // MARK: - Private

    private func updateTransform() {
        var newTransform = CATransform3DIdentity
        newTransform = CATransform3DScale(newTransform, scale, scale, 1)
        newTransform = CATransform3DRotate(newTransform, rotation, 0, 0, 1)
        transform = newTransform
    }
}
