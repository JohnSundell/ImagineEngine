/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal final class PluginManager: Activatable {
    private var plugins = [TypeIdentifier : [ObjectIdentifier : PluginWrapper]]()
    private weak var game: Game?

    // MARK: - API

    func add<P: Plugin>(_ pluginProvider: () -> P, for object: P.Object, reuseExistingOfSameType: Bool) -> P {
        let typeIdentifier = TypeIdentifier(type: P.self)

        if reuseExistingOfSameType {
            if let existingPlugin = plugins[typeIdentifier]?.first?.value {
                return existingPlugin.wrapped as! P
            }
        }

        let plugin = pluginProvider()
        let identifier = ObjectIdentifier(plugin)
        let wrapper = PluginWrapper(plugin: plugin, object: object)

        var pluginsOfType = plugins[typeIdentifier] ?? [:]
        pluginsOfType[identifier] = wrapper
        plugins[typeIdentifier] = pluginsOfType

        game.map(wrapper.activate)

        return plugin
    }

    func remove<P: Plugin>(_ plugin: P, from object: P.Object) {
        let typeIdentifier = TypeIdentifier(type: P.self)
        let identifier = ObjectIdentifier(plugin)

        let plugin = plugins[typeIdentifier]?.removeValue(forKey: identifier)
        plugin?.deactivate()
    }

    func removePlugins<P: Plugin>(ofType: P.Type, from object: P.Object) {
        let typeIdentifier = TypeIdentifier(type: P.self)

        guard let pluginsOfType = plugins.removeValue(forKey: typeIdentifier) else {
            return
        }

        for plugin in pluginsOfType.values {
            plugin.deactivate()
        }
    }

    // MARK: - Activatable

    func activate(in game: Game) {
        self.game = game

        for pluginCollection in plugins.values {
            for plugin in pluginCollection.values {
                plugin.activate(in: game)
            }
        }
    }

    func deactivate() {
        game = nil

        for pluginCollection in plugins.values {
            for plugin in pluginCollection.values {
                plugin.deactivate()
            }
        }
    }
}

private extension PluginManager {
    struct TypeIdentifier: Hashable {
        static func ==(lhs: TypeIdentifier, rhs: TypeIdentifier) -> Bool {
            return lhs.identifier == rhs.identifier
        }

        var hashValue: Int { return identifier.hashValue }
        private let identifier: ObjectIdentifier

        init<T>(type: T.Type) {
            identifier = ObjectIdentifier(type)
        }
    }
}
