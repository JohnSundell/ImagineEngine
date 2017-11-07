/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Protocol adopted by types that can be extended using plugins
 *
 *  Imagine Engine enables you to extend the functionality of several kinds of
 *  objects through Plugins (see the `Plugin` protocol for more info). This lets
 *  you easily decouple your game logic and share code between projects.
 */
public protocol Pluggable: class {
    /// The target of the plugin, usually the object iself
    associatedtype PluginTarget = Self

    /// Add a plugin to this object or reuse an existing instance of the same type (default)
    /// - Returns: The plugin that was either added or reused
    func add<P: Plugin>(_ plugin: @autoclosure () -> P, reuseExistingOfSameType: Bool) -> P where P.Object == PluginTarget

    /// Remove a plugin from this object
    func remove<P: Plugin>(_ plugin: P) where P.Object == PluginTarget

    /// Remove all plugins of a certain type from this object
    func removePlugins<P: Plugin>(ofType type: P.Type) where P.Object == PluginTarget
}

public extension Pluggable {
    /// Add a plugin to this object, reusing an existing instance of the same type if possible
    /// - Returns: The plugin that was either added or reused
    @discardableResult func add<P: Plugin>(_ plugin: @autoclosure () -> P) -> P where P.Object == PluginTarget {
        return add(plugin, reuseExistingOfSameType: true)
    }
}
