/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  Copyright (c) Guilherme Rambo 2017
 *  See LICENSE file for license
 */

import Foundation
import CoreVideo

internal final class DisplayLink: DisplayLinkProtocol {
    var callback: () -> Void = {}
    private var link: CVDisplayLink?

    deinit {
        guard let link = link else {
            return
        }

        CVDisplayLinkStop(link)
    }

    func activate() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)

        guard let link = link else {
            return
        }

        let opaquePointerToSelf = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkSetOutputCallback(link, _imageEngineDisplayLinkCallback, opaquePointerToSelf)

        CVDisplayLinkStart(link)
    }

    @objc func screenDidRender() {
        DispatchQueue.main.async(execute: callback)
    }
}

// swiftlint:disable:next function_parameter_count
private func _imageEngineDisplayLinkCallback(displayLink: CVDisplayLink,
                                             _ now: UnsafePointer<CVTimeStamp>,
                                             _ outputTime: UnsafePointer<CVTimeStamp>,
                                             _ flagsIn: CVOptionFlags,
                                             _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                                             _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
    unsafeBitCast(displayLinkContext, to: DisplayLink.self).screenDidRender()
    return kCVReturnSuccess
}
