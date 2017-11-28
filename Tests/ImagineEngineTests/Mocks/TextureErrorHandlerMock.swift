/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  Copyright (c) Vijay Tholpadi 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

final class TextureErrorHandlerMock: TextureErrorHandler {
    private(set) var didLog = false
    private(set) var didAssert = false

    func log(errorMessage: String) {
        didLog = true
    }

    func assert(errorMessage: String) {
        didAssert = true
    }
}
