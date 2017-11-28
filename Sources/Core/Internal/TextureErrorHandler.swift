/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  Copyright (c) Vijay Tholpadi 2017
 *  See LICENSE file for license
 */

import Foundation

internal protocol TextureErrorHandler {
    func log(errorMessage: String)
    func assert(errorMessage: String)
}
