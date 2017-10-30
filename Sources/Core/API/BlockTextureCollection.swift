/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// A collection of textures that a Block can render
public struct BlockTextureCollection {
    /// The top texture, tiled horizontally if needed
    public var top: Texture?
    /// The top left texture
    public var topLeft: Texture?
    /// The top right texture
    public var topRight: Texture?
    /// The right texture, tiled vertically if needed
    public var right: Texture?
    /// The left texture, tiled vertically if needed
    public var left: Texture?
    /// The center texture, tiled both horizontally & vertically if needed
    public var center: Texture?
    /// The bottom texture, tiled horizontally if needed
    public var bottom: Texture?
    /// The bottom left texture
    public var bottomLeft: Texture?
    /// The bottom right texture
    public var bottomRight: Texture?

    /// Initialize an instance, optionally with a name
    /// If a name is given, then textures will automatically be assigned to
    /// all properties using the property name as a suffix for the texture's
    /// name. This enables you to create a folder containing textures for a
    /// block and simply reference them using the folder's name.
    public init(name: String? = nil, textureFormat: TextureFormat = .png) {
        guard let name = name else {
            return
        }

        top = Texture(name: "\(name)/top", format: textureFormat)
        topLeft = Texture(name: "\(name)/topLeft", format: textureFormat)
        topRight = Texture(name: "\(name)/topRight", format: textureFormat)
        right = Texture(name: "\(name)/right", format: textureFormat)
        left = Texture(name: "\(name)/left", format: textureFormat)
        center = Texture(name: "\(name)/center", format: textureFormat)
        bottom = Texture(name: "\(name)/bottom", format: textureFormat)
        bottomLeft = Texture(name: "\(name)/bottomLeft", format: textureFormat)
        bottomRight = Texture(name: "\(name)/bottomRight", format: textureFormat)
    }
}
