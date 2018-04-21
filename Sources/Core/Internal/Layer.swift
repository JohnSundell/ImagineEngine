/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

internal final class Layer: CALayer {
    // MARK: - Initializers

    override init() {
        super.init()

        #if os(macOS)
        isGeometryFlipped = true
        #endif
    }

    required init?(coder decoder: NSCoder) {
        fatalError("The Layer class cannot be decoded")
    }

    // MARK: - CALayer

    override func action(forKey event: String) -> CAAction? {
        return NSNull()
    }
}
