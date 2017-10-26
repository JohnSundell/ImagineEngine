/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Type used to describe a sprite sheet used with an animation
 *
 *  A sprite sheet is a single texture that contains multiple frames
 *  of an animation. Its texture can have multiple rows and any number
 *  of frames, but it's important that the source image contains evenly
 *  divided frames.
 *
 *  For example, if a sprite sheet is 100x100 pixels large and it is said
 *  to have 16 frames and 4 rows, then each frame is assumed to be a 25x25
 *  cutout from the sprite sheet's texture.
 *
 *  To use a sprite sheet with an animation, either assign it as its `content`
 *  property, or use the initializer `Animation(spriteSheetNamed:...)`.
 */
public struct SpriteSheet {
    /// The texture that makes up the sprite sheet's frames
    public var texture: Texture
    /// The total number of frames contained within the sprite sheet
    public var frameCount: Int
    /// The number of rows that the sprite sheet contains
    public var rowCount: Int

    /// Initialize an instance with a texture + number of frames & rows
    public init(texture: Texture, frameCount: Int, rowCount: Int = 1) {
        self.texture = texture
        self.frameCount = frameCount
        self.rowCount = rowCount
    }
}
