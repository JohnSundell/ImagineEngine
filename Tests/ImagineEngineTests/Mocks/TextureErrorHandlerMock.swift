//
//  TextureErrorHandlerMock.swift
//  ImagineEngine
//
//  Created by Vijay on 21/11/17.
//  Copyright © 2017 ImagineEngine. All rights reserved.
//

import Foundation
@testable import ImagineEngine

class TextureErrorHandlerMock: TextureErrorHandler {
    
    var didIgnore: Bool { return !didLog && !didAssert }
    var didLog = false
    var didAssert = false
    
    func log(errorMessage: String) {
        didLog = true
    }
    
    func assert(errorMessage: String) {
        didAssert = true
    }
}
