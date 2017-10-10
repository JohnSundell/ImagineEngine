/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal enum UpdateOutcome {
    case continueAfter(TimeInterval)
    case finished
}
