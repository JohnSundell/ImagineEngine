/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

internal final class DisplayLink: DisplayLinkProtocol {
    var callback: () -> Void = {}
    private lazy var link = makeLink()

    deinit {
        link.remove(from: .main, forMode: .common)
    }

    func activate() {
        link.add(to: .main, forMode: .common)
    }

    // MARK: - Private

    private func makeLink() -> CADisplayLink {
        return CADisplayLink(target: self, selector: #selector(screenDidRender))
    }

    @objc private func screenDidRender() {
        callback()
    }
}
