//
//  Screen+macOS.swift
//  ImagineEngine-iOS
//
//  Created by Guilherme Rambo on 14/10/17.
//  Copyright © 2017 ImagineEngine. All rights reserved.
//

import Cocoa

extension Screen {
    static var mainScreenScale: CGFloat {
        return Screen.main?.backingScaleFactor ?? 1
    }
}
