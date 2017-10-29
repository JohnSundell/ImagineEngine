/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal extension Font {
    static var `default`: Font {
        #if os(tvOS)
        // Apple's recommended body text point size for tvOS
        return .systemFont(ofSize: 29)
        #else
        return .systemFont(ofSize: Font.systemFontSize)
        #endif
    }
}
