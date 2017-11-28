/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  Copyright (c) Vijay Tholpadi 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

class TextureErrorHandlerMock: TextureErrorHandler {
    var didLog = false
    var didAssert = false

    func log(errorMessage: String) {
        didLog = true
    }

    func assert(errorMessage: String) {
        didAssert = true
    }
}
