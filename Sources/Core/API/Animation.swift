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
    /// The textures that make up the frames of the animation
    public var frames: [Texture] { didSet { updateIdentifier() } }
    /// The duration for which each frame should be rendered
    public var frameDuration = TimeInterval(1)
    /// How the animation should be repeated
    public var repeatMode = RepeatMode.forever
    /// Whether the actor performing the animation should be resized according to each frame
    public var autoResize = true
    /// Whether the actor's `textureNamePrefix` should be ignored for this animation
    public var ignoreTextureNamePrefix = false
    /// Any explicit scale that should be used when loading textures for this animation
    public var textureScale: Int? = nil

    private var identifier = ""
}

public extension Animation {
    init(name: String,
         frameCount: Int,
         frameDuration: TimeInterval,
         frameIndexSeparator: String = "/",
         repeatMode: RepeatMode = .forever,
         autoResize: Bool = true,
         ignoreTextureNamePrefix: Bool = false) {
        frames = (0..<frameCount).map { Texture(name: "\(name)\(frameIndexSeparator)\($0)") }
        self.frameDuration = frameDuration
        self.repeatMode = repeatMode
        self.autoResize = autoResize
        self.ignoreTextureNamePrefix = ignoreTextureNamePrefix
        updateIdentifier()
    }
    
    init(textureNamed textureName: String) {
        frames = [Texture(name: textureName)]
        updateIdentifier()
    }

    init(texturesNamed textureNames: [String], frameDuration: TimeInterval = 1) {
        frames = textureNames.map(Texture.init)
        self.frameDuration = frameDuration
        updateIdentifier()
    }

    init(image: Image) {
        frames = [Texture(image: image)]
        updateIdentifier()
    }
}

internal extension Animation {
    var totalDuration: TimeInterval {
        switch repeatMode {
        case .times(let count):
            return TimeInterval(count) * TimeInterval(frames.count) * frameDuration
        case .forever:
            return .infinity
        }
    }
}

private extension Animation {
    mutating func updateIdentifier() {
        var newIdentifier = ""

        for frame in frames {
            newIdentifier.append("\(frame.name)-")
        }

        identifier = newIdentifier
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
