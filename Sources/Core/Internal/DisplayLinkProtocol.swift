/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal protocol DisplayLinkProtocol: class {
    var callback: () -> Void { get set }
    func activate()
}
