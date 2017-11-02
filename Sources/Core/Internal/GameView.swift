/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal class GameView: View {
    override var frame: Rect { didSet { game?.scene.camera.size = frame.size } }
    weak var game: Game?

    #if os(macOS)
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        game?.updateActivationStatus()
    }
    #else
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        game?.updateActivationStatus()
    }

    override func safeAreaInsetsDidChange() {
        if #available(iOS 11, tvOS 11, *) {
            super.safeAreaInsetsDidChange()
            game?.scene.safeAreaInsets = safeAreaInsets
        }
    }
    #endif
}
