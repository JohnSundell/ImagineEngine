/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Events that can be used to observe an label
public final class LabelEventCollection: EventCollection<Label> {
    /// Event triggered when the label was clicked (on macOS) or tapped (on iOS/tvOS)
    public private(set) lazy var clicked = Event<Label, Void>(object: object)
    /// Event triggered when the label was rotated
    public private(set) lazy var rotated = Event<Label, Void>(object: object)
}
