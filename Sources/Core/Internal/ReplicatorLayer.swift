/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

internal final class ReplicatorLayer: CAReplicatorLayer {
    override init() {
        super.init()

        #if os(macOS)
        isGeometryFlipped = true
        #endif
    }

    required init?(coder decoder: NSCoder) {
        fatalError("The ReplicatorLayer class cannot be decoded")
    }

    override func action(forKey event: String) -> CAAction? {
        return NSNull()
    }
}
