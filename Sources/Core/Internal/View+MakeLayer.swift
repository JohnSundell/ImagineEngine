/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

internal extension View {
    func makeLayerIfNeeded() -> CALayer {
        #if os(OSX)
        wantsLayer = true
        return layer!
        #else
        return layer
        #endif
    }
}
