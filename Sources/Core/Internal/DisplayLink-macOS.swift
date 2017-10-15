//
//  DisplayLink-macOS.swift
//  ImagineEngine-iOS
//
//  Created by Guilherme Rambo on 14/10/17.
//  Copyright © 2017 ImagineEngine. All rights reserved.
//

import Foundation
import CoreVideo

internal final class DisplayLink: DisplayLinkProtocol {
    var callback: () -> Void = {}
    private var link: CVDisplayLink?
    
    deinit {
        guard let link = link else { return }
        
        CVDisplayLinkStop(link)
    }
    
    func activate() {
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        
        guard let link = link else { return }
        
        let opaquePointerToSelf = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkSetOutputCallback(link, _imageEngineDisplayLinkCallback, opaquePointerToSelf)
        
        CVDisplayLinkStart(link)
    }
    
    // MARK: - Private
    
    @objc internal func screenDidRender() {
        callback()
    }
    
}

private func _imageEngineDisplayLinkCallback(displayLink: CVDisplayLink, _ now: UnsafePointer<CVTimeStamp>, _ outputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
    unsafeBitCast(displayLinkContext, to: DisplayLink.self).screenDidRender()
    return kCVReturnSuccess
}
