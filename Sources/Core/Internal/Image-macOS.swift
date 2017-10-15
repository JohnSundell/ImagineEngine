//
//  Image+macOS.swift
//  ImagineEngine-iOS
//
//  Created by Guilherme Rambo on 14/10/17.
//  Copyright © 2017 ImagineEngine. All rights reserved.
//

import Cocoa

extension Image {
    
    var cgImage: CGImage? {
        return cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    var scale: CGFloat {
        // TODO: find a better way of figuring out the image scale factor on macOS
        return NSScreen.main?.backingScaleFactor ?? 1.0
    }
    
}
