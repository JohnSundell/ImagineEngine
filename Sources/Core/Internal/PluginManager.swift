/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class PluginManager: Activatable {
    private var plugins = [ObjectIdentifier : PluginWrapper]()
    private weak var game: Game?

    // MARK: - API

    func add<P: Plugin>(_ pluginProvider: () -> P, for object: P.Object) -> P {
        let identifier = ObjectIdentifier(P.self)

        if let existingPlugin = plugins[identifier] {
            return existingPlugin.wrapped as! P
        }

        let plugin = pluginProvider()
        let wrapper = PluginWrapper(plugin: plugin, object: object)
        plugins[identifier] = wrapper
        game.map(wrapper.activate)

        return plugin
    }

    func remove<P: Plugin>(_ plugin: P, from object: P.Object) {
        let identifier = ObjectIdentifier(P.self)
        plugins.removeValue(forKey: identifier)?.deactivate()
    }

    // MARK: - Activatable

    func activate(in game: Game) {
        self.game = game

        for plugin in plugins.values {
            plugin.activate(in: game)
        }
    }

    func deactivate() {
        game = nil

        for plugin in plugins.values {
            plugin.deactivate()
        }
    }
}
