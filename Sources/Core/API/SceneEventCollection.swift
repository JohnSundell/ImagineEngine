/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Events that can be used to observe a scene
public final class SceneEventCollection: EventCollection<Scene> {
    /// Event that will be triggered when the scene was clicked or tapped
    public private(set) lazy var clicked: Event<Scene, Point> = self.makeClickedEvent()

    private func makeClickedEvent() -> Event<Scene, Point> {
        object?.add(ClickPlugin())
        return Event<Scene, Point>(object: object)
    }
}
