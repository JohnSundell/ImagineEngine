/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/// Token that can be used to cancel an event observation
public final class EventToken: CancellationToken {
    internal let identifier = UUID()
}
