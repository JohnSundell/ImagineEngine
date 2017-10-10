/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Protocol used to define plugins for Imagine Engine
 *
 *  You can use plugins to inject your own logic into a game object
 *  or scene. Plugins are activated whenever the game starts (or if
 *  they're added when the game is already running) and are deactivated
 *  when their object is removed from the game.
 *
 *  You attach plugins to objects using their `add()` method, like this:
 *
 *  ```
 *  class MyPlugin: Plugin {
 *      func activate(for object: Actor, in game: Game) {
 *          // Perform your logic
 *      }
 *  }
 *
 *  actor.add(MyPlugin())
 *  ```
 */
public protocol Plugin: class {
    /// The type of object that the plugin is compatible with
    associatedtype Object: AnyObject

    /// Activate the plugin for a given object in a game
    func activate(for object: Object, in game: Game)

    /// Deactivate the plugin
    func deactivate()
}

public extension Plugin {
    func deactivate() {}
}
