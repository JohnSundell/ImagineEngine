/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

final class GameMock: Game {
    let timeTraveler = TimeTraveler()
    let textureImageLoader = TextureImageLoaderMock()

    private let displayLink = DisplayLinkMock()
    private let containerView = View()

    init() {
        let scene = Scene(size: Size(width: 500, height: 500))
        scene.textureManager.imageLoader = textureImageLoader

        super.init(size: scene.size,
                   scene: scene,
                   displayLink: displayLink,
                   dateProvider: timeTraveler.generateDate)

        view.frame.size = scene.size
        containerView.addSubview(view)
        updateActivationStatus()
    }

    func update() {
        displayLink.callback()
    }
}
