import Foundation
import QuartzCore

internal extension CALayer {
    func applyTransform(withRotation rotation: Metric,
                        scale: Metric,
                        mirroring: Set<Mirroring>) {
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
