/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  Copyright (c) Guilherme Rambo 2017
 *  See LICENSE file for license
 */

import Cocoa

extension Image {
    var cgImage: CGImage? {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    var scale: CGFloat {
        // TODO: find a better way of figuring out the image scale factor on macOS
        return Screen.mainScreenScale
    }
}
