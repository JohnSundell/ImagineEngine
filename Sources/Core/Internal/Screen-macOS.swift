/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  Copyright (c) Guilherme Rambo 2017
 *  See LICENSE file for license
 */

import Cocoa

internal extension Screen {
    static var mainScreenScale: CGFloat {
        return Screen.main?.backingScaleFactor ?? 1
    }
}
