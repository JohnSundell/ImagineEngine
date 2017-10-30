/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Enum defining supported texture formats.
public enum TextureFormat {
    /// PNG format.
    case png
    /// JPG/JPEG format.
    case jpg
    /// Unknown format. It is being used exclusively for cases when pre-loaded image is provided for the texture and no loading is performed.
    case unknown

    /// Extension name for the texture format that will be used for locating and loading particular texture image.
    var extensionName: String? {
        switch self {
        case .png:
            return "png"
        case .jpg:
            return "jpg"
        case .unknown:
            return nil
        }
    }
}
