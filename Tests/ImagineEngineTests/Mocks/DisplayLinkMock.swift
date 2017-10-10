/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

final class DisplayLinkMock: DisplayLinkProtocol {
    var callback: () -> Void = {}
    private(set) var isActivated = false

    func activate() {
        assert(!isActivated, "A display link should only be activated once")
        isActivated = true
    }
}
