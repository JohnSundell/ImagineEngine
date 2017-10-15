//
//  GameWindowController.swift
//  ImagineEngine-iOS
//
//  Created by Guilherme Rambo on 14/10/17.
//  Copyright © 2017 ImagineEngine. All rights reserved.
//

import Cocoa

public class GameWindowController: NSWindowController {
    
    /// The game that the window controller is managing
    public var game: Game { return gameViewController.game }
    
    /// The game view controller that's presenting the game managed by the window controller
    public var gameViewController: GameViewController { return contentViewController as! GameViewController }
    
    public convenience init(scene: Scene? = nil) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 640, height: 360), styleMask: [.closable, .miniaturizable, .resizable, .titled], backing: .buffered, defer: false)
        
        self.init(window: window)
        
        window.center()
        
        let effectiveScene = scene ?? Scene(size: window.contentRect(forFrameRect: window.frame).size)
        contentViewController = GameViewController(scene: effectiveScene)
    }
    
}
