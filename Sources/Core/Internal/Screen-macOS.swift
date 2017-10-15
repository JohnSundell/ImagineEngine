//
//  Screen+macOS.swift
//  ImagineEngine-iOS
//
//  Created by Guilherme Rambo on 14/10/17.
//  Copyright © 2017 ImagineEngine. All rights reserved.
//

#if os(OSX)
    import Cocoa
#endif

extension Screen {
    
    static var mainScreenScale: CGFloat {
        #if os(OSX)
            return Screen.main?.scale ?? 1.0
        #else
            return Screen.main.scale
        #endif
    }
    
    #if os(OSX)
    var scale: CGFloat {
        return backingScaleFactor
    }
    #endif
    
}
