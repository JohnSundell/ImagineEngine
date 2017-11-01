/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal protocol BundleProtocol {
    func url(forResource name: String?, withExtension ext: String?) -> URL?
}

extension Bundle: BundleProtocol {}
