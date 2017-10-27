/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

final class ClickGestureRecognizerMock: ClickGestureRecognizer {
    var location: Point?

    override func location(in view: View?) -> Point {
        if let location = location {
            return location
        }

        return super.location(in: view)
    }
}
