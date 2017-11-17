/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal protocol SceneObject: Activatable {
    var scene: Scene? { get set }
    func addLayer(to superlayer: Layer)
}
