/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
@testable import ImagineEngine

final class GameMock: Game {
    let mockedView = GameViewMock()
    let timeTraveler = TimeTraveler()
    let textureImageLoader = TextureImageLoaderMock()

    private let displayLink = DisplayLinkMock()
    private let containerView = View()
    private let clickGestureRecognizer = ClickGestureRecognizerMock()
    private lazy var clickPlugin = ClickPlugin(gestureRecognizer: clickGestureRecognizer)

    init() {
        let scene = Scene(size: Size(width: 500, height: 500))
        scene.textureManager.imageLoader = textureImageLoader

        super.init(view: mockedView,
                   scene: scene,
                   displayLink: displayLink,
                   dateProvider: timeTraveler.generateDate)

        scene.add(clickPlugin, reuseExistingOfSameType: false)

        view.frame.size = scene.size
        containerView.addSubview(view)
        updateActivationStatus()
    }

    func update() {
        displayLink.callback()
    }

    func simulateClick(at point: Point) {
        // The mac's coordinate system has its origin in the bottom left
        #if os(macOS)
        var point = point
        point.y = view.bounds.height - point.y
        #endif

        clickGestureRecognizer.location = point
        clickPlugin.trigger()
        clickGestureRecognizer.location = nil
    }
}
