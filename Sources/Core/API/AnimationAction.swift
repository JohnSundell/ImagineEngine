/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Action used to make an actor play an animation
public final class AnimationAction: Action<Actor> {
    private let animation: Animation
    private let triggeredByActor: Bool
    private var frameIndex = 0
    private var repeatCount = 0

    // MARK: - Initializers

    /// Initialize an instance of this action with an animation
    public init(animation: Animation) {
        self.animation = animation
        self.triggeredByActor = false
        super.init(duration: animation.totalDuration)
    }

    internal init(animation: Animation, triggeredByActor: Bool) {
        self.animation = animation
        self.triggeredByActor = triggeredByActor
        super.init(duration: animation.totalDuration)
    }

    // MARK: - Action

    public override func start(for actor: Actor) {
        if !triggeredByActor {
            actor.animation = animation
        }
    }

    internal override func update(for actor: Actor, currentTime: TimeInterval) -> UpdateOutcome {
        let frame = animation.frames[frameIndex]
        frameIndex += 1

        actor.render(texture: frame,
                     scale: animation.textureScale,
                     resize: animation.autoResize,
                     ignoreNamePrefix: animation.ignoreTextureNamePrefix)

        if animation.frames.count < 2 {
            return .finished
        }

        if frameIndex == animation.frames.count {
            switch animation.repeatMode {
            case .times(let count):
                guard repeatCount < count else {
                    actor.animation = nil
                    return .finished
                }
            case .forever:
                break
            }

            repeatCount += 1
            frameIndex = 0
        }

        return .continueAfter(animation.frameDuration)
    }
}
