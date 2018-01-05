/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Events that can be used to observe a camera
public final class CameraEventCollection: EventCollection<Camera> {
    /// Event triggered when the camera was moved
    public private(set) lazy var moved = Event<Camera, (old: Point, new: Point)>(object: object)
    /// Event triggered when the camera was resized
    public private(set) lazy var resized = Event<Camera, Void>(object: object)
    /// Event triggered when the camera was clicked (on macOS) or tapped (on iOS/tvOS)
    public private(set) lazy var clicked = Event<Camera, Point>(object: object)
}
