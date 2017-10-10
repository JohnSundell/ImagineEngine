/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Structure used to define a texture that should be loaded into a game
/// You can reference a texture either by name or by using a pre-loaded image
public struct Texture {
    /// The name of the texture to load
    public let name: String
    /// Any pre-loaded image that should make up the texture
    public let image: Image?

    /// Initialize a texture with the name of a bundled image to load
    public init(name: String) {
        self.name = name
        self.image = nil
    }

    /// Initialize a texture with a pre-loaded image
    public init(image: Image) {
        self.name = "InlineImage-\(image.hashValue)"
        self.image = image
    }
}
