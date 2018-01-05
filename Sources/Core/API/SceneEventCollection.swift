/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Events that can be used to observe a scene
public final class SceneEventCollection: EventCollection<Scene> {
    /// Event that gets triggered when the scene was clicked or tapped
    public private(set) lazy var clicked = Event<Scene, Point>(object: object)
    /// Event that gets triggered when an actor was added to the scene
    public private(set) lazy var actorAdded = Event<Scene, Actor>(object: object)
    /// Event that gets triggered when an actor was removed from the scene
    public private(set) lazy var actorRemoved = Event<Scene, Actor>(object: object)
    /// Event that gets triggered when the scene was resized
    public private(set) lazy var resized = Event<Scene, Void>(object: object)
    /// Event that gets triggered when its safe area insets changed
    public private(set) lazy var safeAreaInsetsChanged = Event<Scene, Void>(object: object)
}
