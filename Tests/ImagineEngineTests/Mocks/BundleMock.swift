/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

final class BundleMock: BundleProtocol {
    private(set) var resourceNames = Set<String>()
    var resources = [String : URL]()

    func url(forResource name: String?, withExtension ext: String?) -> URL? {
        guard let name = name else {
            return nil
        }
        let resourceName = self.resourceName(name, withExtension: ext)
        resourceNames.insert(resourceName)
        return resources[resourceName]
    }

    private func resourceName(_ name: String, withExtension ext: String?) -> String {
        var resourceName = name

        if let ext = ext {
            resourceName.append(".\(ext)")
        }

        return resourceName
    }
}
