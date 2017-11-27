/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Type used to describe an animation that can be performed by an Actor
 *
 *  An animation consists of frames that are rendered by an actor in sequence,
 *  based on a given `frameDuration`. The textures that make up an animation's
 *  frames can either be defined explicitly, or be interred based on the name
 *  of the animation + the index of the frame. You can also tweak other properties
 *  of an animation, including its repeat mode and whether the actor should be
 *  resized when performing it.
 *
 *  Example usage:
 *  ```
 *  let player = Actor()
 *  player.animation = Animation(textureNamed: "Idle")
 *  ```
 */
public struct Animation {
    /// The content that make up the frames of the animation
    public var content: Content { didSet { updateIdentifier() } }
    /// The duration for which each frame should be rendered
    public var frameDuration = TimeInterval(1)
    /// How the animation should be repeated
    public var repeatMode = RepeatMode.forever
    /// Whether the actor performing the animation should be resized according to each frame
    public var autoResize = true
    /// Whether the actor's `textureNamePrefix` should be ignored for this animation
    public var ignoreTextureNamePrefix = false
    /// Any explicit scale that should be used when loading textures for this animation
    public var textureScale: Int?

    private var identifier = ""
}

public extension Animation {
    /// Initialize an instance with its various parameters. See the documentation for
    /// each property for more information.
    init(name: String,
         frameCount: Int,
         frameDuration: TimeInterval,
         frameIndexSeparator: String = "/",
         repeatMode: RepeatMode = .forever,
         autoResize: Bool = true,
         ignoreTextureNamePrefix: Bool = false) {
        self.content = .frames(withBaseName: name, indexSeparator: frameIndexSeparator, count: frameCount)
        self.frameDuration = frameDuration
        self.repeatMode = repeatMode
        self.autoResize = autoResize
        self.ignoreTextureNamePrefix = ignoreTextureNamePrefix
        updateIdentifier()
    }

    /// Initialize an instance with a single texture with a certain image name
    init(textureNamed textureName: String, scale: Int? = nil, format: TextureFormat? = nil) {
        content = .texture(Texture(name: textureName, format: format))
        textureScale = scale
        updateIdentifier()
    }

    /// Initialize an instance with a sequence of textures loaded from an array of image names
    init(texturesNamed textureNames: [String], format: TextureFormat? = nil, frameDuration: TimeInterval) {
        content = .textures(textureNames.map { Texture(name: $0, format: format) })
        self.frameDuration = frameDuration
        updateIdentifier()
    }

    /// Initialize an instance with an image to use for the animation
    init(image: Image) {
        content = .texture(Texture(image: image))
        updateIdentifier()
    }

    /// Initialize an instance with an array of images to use for the animation
    init(images: [Image], frameDuration: TimeInterval) {
        content = .textures(images.map(Texture.init))
        self.frameDuration = frameDuration
        updateIdentifier()
    }

    /// initialize an instance with a sprite sheet from a given image name
    init(spriteSheetNamed name: String,
         frameCount: Int,
         rowCount: Int,
         frameDuration: TimeInterval,
         repeatMode: RepeatMode = .forever,
         autoResize: Bool = true,
         ignoreTextureNamePrefix: Bool = false,
         textureFormat: TextureFormat? = nil) {
        let texture = Texture(name: name, format: textureFormat)
        let spriteSheet = SpriteSheet(texture: texture, frameCount: frameCount, rowCount: rowCount)
        content = .spriteSheet(spriteSheet)

        self.frameDuration = frameDuration
        self.repeatMode = repeatMode
        self.autoResize = autoResize
        self.ignoreTextureNamePrefix = ignoreTextureNamePrefix

        updateIdentifier()
    }
}

public extension Animation {
    /// Enum describing types of content that an animation can be made up of
    enum Content {
        /// The animation consists of a series of separate textures
        case textures([Texture])
        /// The animation is powered by a single texture used as a sprite sheet
        case spriteSheet(SpriteSheet)
    }
}

internal extension Animation {
    struct Frame {
        let texture: Texture
        let contentRect: Rect
    }

    var frameCount: Int {
        switch content {
        case .textures(let textures):
            return textures.count
        case .spriteSheet(let sheet):
            return sheet.frameCount
        }
    }

    var totalDuration: TimeInterval {
        switch repeatMode {
        case .times(let count):
            return TimeInterval(count) * TimeInterval(frameCount) * frameDuration
        case .forever:
            return .infinity
        }
    }

    func frame(at index: Int) -> Frame {
        switch content {
        case .textures(let textures):
            let contentRect = Rect(x: 0, y: 0, width: 1, height: 1)
            return Frame(texture: textures[index], contentRect: contentRect)
        case .spriteSheet(let sheet):
            let framesPerRow = sheet.frameCount / sheet.rowCount
            let rowIndex = index / framesPerRow
            let column = index - rowIndex * framesPerRow

            #if os(macOS)
            let row = sheet.rowCount - 1 - rowIndex
            #else
            let row = rowIndex
            #endif

            var contentRect = Rect()
            contentRect.origin.x = Metric(column) / Metric(framesPerRow)
            contentRect.origin.y = Metric(row) / Metric(sheet.rowCount)
            contentRect.size.width = 1 / Metric(framesPerRow)
            contentRect.size.height = 1 / Metric(sheet.rowCount)

            return Frame(texture: sheet.texture, contentRect: contentRect)
        }
    }
}

private extension Animation {
    mutating func updateIdentifier() {
        var newIdentifier = ""

        switch content {
        case .textures(let textures):
            for texture in textures {
                newIdentifier.append("\(texture.name)-")
            }
        case .spriteSheet(let sheet):
            newIdentifier = "\(sheet.texture.name)-\(sheet.frameCount)-\(sheet.rowCount)"
        }

        identifier = newIdentifier
    }
}

private extension Animation.Content {
    static func frames(withBaseName name: String, indexSeparator: String, count: Int) -> Animation.Content {
        let frames = (0..<count).map { Texture(name: "\(name)\(indexSeparator)\($0)") }
        return .textures(frames)
    }

    static func texture(_ texture: Texture) -> Animation.Content {
        return .textures([texture])
    }
}

extension Animation: Equatable {
    public static func ==(lhs: Animation, rhs: Animation) -> Bool {
        guard lhs.identifier == rhs.identifier else {
            return false
        }

        guard lhs.frameDuration == rhs.frameDuration else {
            return false
        }

        guard lhs.repeatMode == rhs.repeatMode else {
            return false
        }

        guard lhs.autoResize == rhs.autoResize else {
            return false
        }

        return true
    }
}
