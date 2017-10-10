/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import UIKit

/// Window that can be used to present & manage an Imagine Engine game
public class GameWindow: UIWindow {
    /// The game that the window is managing
    public var game: Game { return viewController.game }
    private let viewController: GameViewController

    /// Initialize an instance of this window, optionally with a scene to present
    public init(frame: CGRect = UIScreen.main.bounds, scene: Scene? = nil) {
        let scene = scene ?? Scene(size: frame.size)
        viewController = GameViewController(scene: scene)
        super.init(frame: frame)
        rootViewController = viewController
    }
    
    required public init?(coder decoder: NSCoder) {
        viewController = GameViewController(scene: Scene(size: .zero))
        super.init(coder: decoder)
        rootViewController = viewController
    }
}
