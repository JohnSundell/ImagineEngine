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
    /// Any area that should be sliced from the sprite sheet's texture
    public var slicedArea: Area?

    /// Initialize an instance with a texture + number of frames & rows
    public init(texture: Texture, frameCount: Int, rowCount: Int = 1) {
        self.texture = texture
        self.frameCount = frameCount
        self.rowCount = rowCount
    }
}

public extension SpriteSheet {
    /// Struct representing an area of a sprite sheet that should be sliced out
    struct Area {
        /// The coordinates that make up the lower (min X/Y) and upper (max X/Y) bounds of the area
        public var coordinates: ClosedRange<Coordinate> { didSet { updateFrameCount() } }
        /// The number of frames that are present within the area
        public private(set) var frameCount = 0

        /// Initialize an instance using a range of coordinates that make up the area
        public init(coordinates: ClosedRange<Coordinate>) {
            self.coordinates = coordinates
            updateFrameCount()
        }

        private mutating func updateFrameCount() {
            let deltaX = coordinates.upperBound.x - coordinates.lowerBound.x + 1
            let deltaY = coordinates.upperBound.y - coordinates.lowerBound.y + 1
            frameCount = deltaX * deltaY
        }
    }

    /// Initialize an instance with a texture with a given name
    init(textureNamed textureName: String, format: TextureFormat? = nil, frameCount: Int, rowCount: Int = 1) {
        let texture = Texture(name: textureName, format: format)
        self.init(texture: texture, frameCount: frameCount, rowCount: rowCount)
    }

    /// Initialize an instance with a given column (width) and row (height) count
    init(textureNamed textureName: String, format: TextureFormat? = nil, columnCount: Int, rowCount: Int) {
        let texture = Texture(name: textureName, format: format)
        let frameCount = columnCount * rowCount
        self.init(texture: texture, frameCount: frameCount, rowCount: rowCount)
    }

    /// Create a slice of this sprite sheet from a range of coordinates
    func slice(from coordinates: ClosedRange<Coordinate>) -> SpriteSheet {
        var sheet = self
        sheet.slicedArea = Area(coordinates: coordinates)
        return sheet
    }
}

internal extension SpriteSheet {
    func frame(at index: Int) -> Animation.Frame {
        guard let area = slicedArea else {
            let rowLength = frameCount / rowCount
            let coordinate = self.coordinate(at: index, rowLength: rowLength, offsetBy: nil)
            return frame(at: coordinate)
        }

        let start = area.coordinates.lowerBound
        let end = area.coordinates.upperBound
        let rowLength = end.x - start.x + 1
        let coordinate = self.coordinate(at: index, rowLength: rowLength, offsetBy: start)
        return frame(at: coordinate)
    }
}

private extension SpriteSheet {
    func coordinate(at index: Int, rowLength: Int, offsetBy offset: Coordinate?) -> Coordinate {
        let y = index / rowLength
        let x = index - y * rowLength

        return Coordinate(
            x: (offset?.x ?? 0) + x,
            y: (offset?.y ?? 0) + y
        )
    }

    func frame(at coordinate: Coordinate) -> Animation.Frame {
        let rowLength = frameCount / rowCount

        var contentRect = Rect()
        contentRect.origin.x = Metric(coordinate.x) / Metric(rowLength)

        #if os(macOS)
        contentRect.origin.y = Metric(rowCount - 1 - coordinate.y) / Metric(rowCount)
        #else
        contentRect.origin.y = Metric(coordinate.y) / Metric(rowCount)
        #endif

        contentRect.size.width = 1 / Metric(rowLength)
        contentRect.size.height = 1 / Metric(rowCount)

        return Animation.Frame(texture: texture, contentRect: contentRect)
    }
}
