/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import UIKit

/**
 *  View controller that can be used to manage & present an Imagine Engine game
 *
 *  This view controller will automatically resize the game to fit its view,
 *  and will pause/resume it as the view controller gets presented or dismissed
 *  (including when the app becomes active or moves to the background).
 */
public class GameViewController: UIViewController {
    /// The game that the view controller is managing
    public let game: Game
    public override var prefersStatusBarHidden: Bool { return true }

    private let notificationCenter: NotificationCenter
    private var gameWasAutoPaused = false

    // MARK: - Lifecycle

    /// Initialize an instance of this class with a game
    public init(game: Game, notificationCenter: NotificationCenter = .default) {
        self.game = game
        self.notificationCenter = notificationCenter
        super.init(nibName: nil, bundle: nil)
    }

    required public init?(coder decoder: NSCoder) {
        game = Game(size: .zero, scene: Scene(size: .zero))
        notificationCenter = .default
        super.init(coder: decoder)
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    // MARK: - UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.isOpaque = true
        view.addSubview(game.view)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        game.scene.isPaused = false
        game.updateActivationStatus()

        notificationCenter.addObserver(self,
           selector: #selector(applicationDidBecomeActive),
           name: .UIApplicationDidBecomeActive,
           object: nil
        )

        notificationCenter.addObserver(self,
            selector: #selector(applicationWillBecomeInactive),
            name: .UIApplicationWillResignActive,
            object: nil
        )
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        game.scene.isPaused = true
        notificationCenter.removeObserver(self)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        game.view.frame = view.bounds
    }

    // MARK: - Observations

    @objc private func applicationDidBecomeActive() {
        if gameWasAutoPaused {
            game.scene.isPaused = false
        }

        gameWasAutoPaused = false
    }

    @objc private func applicationWillBecomeInactive() {
        guard !game.scene.isPaused else {
            return
        }

        game.scene.isPaused = true
        gameWasAutoPaused = true
    }
}

public extension GameViewController {
    convenience init(scene: Scene) {
        self.init(game: Game(size: .zero, scene: scene))
    }
}
