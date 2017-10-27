/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Events that can be used to observe an actor
public final class ActorEventCollection: EventCollection<Actor> {
    /// Event triggered when the actor is about to move (contains the new position)
    public private(set) lazy var willMove = Event<Actor, Point>(object: self.object)
    /// Event triggered when the actor was moved
    public private(set) lazy var moved = Event<Actor, Void>(object: self.object)
    /// Event triggered when the actor was resized
    public private(set) lazy var resized = Event<Actor, Void>(object: self.object)
    /// Event triggered when the actor's rectangle changed (either by position or size)
    public private(set) lazy var rectChanged = Event<Actor, Void>(object: self.object)
    /// Event triggered when the actor's velocity changed
    public private(set) lazy var velocityChanged = Event<Actor, Void>(object: self.object)
    /// Event triggered when the actor collided with any other actor
    public private(set) lazy var collidedWithAnyActor = Event<Actor, Actor>(object: self.object)
    /// Event triggered when the actor collided with any block
    public private(set) lazy var collidedWithAnyBlock = Event<Actor, Block>(object: self.object)
    /// Event triggered when the actor exited its scene
    public private(set) lazy var leftScene = Event<Actor, Void>(object: self.object)
    /// Event triggered when the actor was clicked (on macOS) or tapped (on iOS/tvOS)
    public private(set) lazy var clicked: Event<Actor, Void> = self.makeClickedEvent()

    /// Event triggered when the actor collided with another actor
    public func collided(with actor: Actor) -> Event<Actor, Actor> {
        return makeEvent(withSubject: actor)
    }

    /// Event triggered when the actor collided with an actor in a given group
    public func collided(withActorInGroup group: Group) -> Event<Actor, Actor> {
        return makeEvent(withSubjectIdentifier: group.identifier)
    }

    /// Event triggered when the actor collided with a block in a given group
    public func collided(withBlockInGroup group: Group) -> Event<Actor, Block> {
        return makeEvent(withSubjectIdentifier: group.identifier)
    }

    private func makeClickedEvent() -> Event<Actor, Void> {
        object?.makeClickable()
        return Event<Actor, Void>(object: object)
    }
}
