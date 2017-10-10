/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

internal final class Layer: CALayer {
    var rotation: Metric = 0 { didSet { updateTransform() } }
    var scale: Metric = 1 { didSet { updateTransform() } }
    var mirroring = Set<Mirroring>() { didSet { updateTransform() } }

    override func action(forKey event: String) -> CAAction? {
        return NSNull()
    }

    private func updateTransform() {
        var newTransform = CATransform3DIdentity
        newTransform = CATransform3DRotate(newTransform, rotation, 0, 0, 1)
        newTransform = CATransform3DScale(newTransform, scale, scale, 1)

        if mirroring.contains(.horizontal) {
            newTransform = CATransform3DScale(newTransform, -1, 1, 1)
        }

        if mirroring.contains(.vertical) {
            newTransform = CATransform3DScale(newTransform, 1, -1, 1)
        }

        transform = newTransform
    }
}
