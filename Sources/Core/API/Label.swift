/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

/**
 *  Class used to render text content in a scene
 *
 *  You can use a label to render text in a scene. It supports features like
 *  setting the font and text color of text and will automatically resize itself
 *  to fit the text you assign to it.
 */
public final class Label: SceneObject, InstanceHashable, ActionPerformer, Pluggable, ZIndexed, Movable, Fadeable, Rotatable {
    /// The scene that the label currently belongs to.
    public internal(set) var scene: Scene?
    /// A collection of events that can be used to observe the label.
    public private(set) lazy var events = LabelEventCollection(object: self)
    /// Whether the label's text should be wrapped on multiple lines in case it doesn't fit its width.
    public var shouldWrap = false { didSet { layer.isWrapped = shouldWrap } }
    /// The index of the label on the z axis. Affects rendering. 0 = implicit index.
    public var zIndex = 0 { didSet { layer.zPosition = Metric(zIndex) } }
    /// The position of the label within its scene.
    public var position = Point() { didSet { positionDidChange(from: oldValue) } }
    /// The size of the label, centered on its position.
    public var size = Size() { didSet { sizeDidChange(from: oldValue) } }
    /// The rotation of the label along the z axis.
    public var rotation = Metric() { didSet { rotationDidChange(from: oldValue) } }
    /// Whether the label should automatically be resized to fit its content.
    public var shouldAutoResize = true
    /// The rectangle that the label currently occupies within its scene.
    public var rect: Rect { return layer.frame }
    /// The opacity of the label. Ranges from 0 (transparent) - 1 (opaque).
    public var opacity = Metric(1) { didSet { layer.opacity = Float(opacity) } }
    /// The text that the label is currently rendering.
    public var text: String { didSet { textDidChange() } }
    /// The font that the label renders its text using.
    public var font: Font { didSet { fontDidChange() } }
    /// The color of the text that the label is rendering.
    public var textColor = Color.white { didSet { layer.foregroundColor = textColor.cgColor } }
    /// The way the label's text should be laid out given excess space
    public var horizontalAlignment = HorizontalAlignment.left { didSet { horizontalAlignmentDidChange() } }
    /// The label's background color. Default is `.clear` (no background).
    public var backgroundColor = Color.clear { didSet { layer.backgroundColor = backgroundColor.cgColor } }

    internal let layer = TextLayer()
    internal private(set) lazy var gridTiles = Set<Grid.Tile>()

    private lazy var actionManager = ActionManager(object: self)
    private let pluginManager = PluginManager()

    // MARK: - Initializer

    /// Initialize an instance, optionally with an initial text
    public init(text: String = "") {
        self.text = text
        font = .default

        layer.string = text
        layer.contentsScale = Screen.mainScreenScale

        fontDidChange()
        horizontalAlignmentDidChange()
    }

    // MARK: - SceneObject

    internal func addLayer(to superlayer: Layer) {
        superlayer.addSublayer(layer)
    }

    internal func add(to gridTile: Grid.Tile) {
        gridTile.labels.insert(self)
        gridTiles.insert(gridTile)
    }

    internal func remove(from gridTile: Grid.Tile) {
        gridTile.labels.remove(self)
        gridTiles.remove(gridTile)
    }

    // MARK: - ActionPerformer

    @discardableResult public func perform(_ action: Action<Label>) -> ActionToken {
        return actionManager.add(action)
    }

    // MARK: - Pluggable

    @discardableResult public func add<P: Plugin>(_ plugin: @autoclosure () -> P,
                                                  reuseExistingOfSameType: Bool) -> P where P.Object == Label {
        return pluginManager.add(plugin, for: self, reuseExistingOfSameType: reuseExistingOfSameType)
    }

    public func plugins<P: Plugin>(ofType type: P.Type) -> [P] where P.Object == Label {
        return pluginManager.plugins(ofType: type)
    }

    public func remove<P: Plugin>(_ plugin: P) where P.Object == Label {
        pluginManager.remove(plugin, from: self)
    }

    public func removePlugins<P: Plugin>(ofType type: P.Type) where P.Object == Label {
        pluginManager.removePlugins(ofType: type, from: self)
    }

    // MARK: - Activatable

    internal func activate(in game: Game) {
        actionManager.activate(in: game)
        pluginManager.activate(in: game)
    }

    internal func deactivate() {
        actionManager.deactivate()
        pluginManager.deactivate()
    }

    // MARK: - Public

    /// Remove the label from its scene
    public func remove() {
        scene?.remove(self)
        scene = nil
        layer.removeFromSuperlayer()
    }

    // MARK: - Private

    private func positionDidChange(from oldValue: Point) {
        guard position != oldValue else {
            return
        }

        layer.position = position
        scene?.labelRectDidChange(self)
    }

    private func sizeDidChange(from oldValue: Size) {
        guard size != oldValue else {
            return
        }

        layer.bounds.size = size
        scene?.labelRectDidChange(self)
    }

    private func textDidChange() {
        layer.string = text
        autoResize()
    }

    private func fontDidChange() {
        layer.font = font
        layer.fontSize = font.pointSize
        autoResize()
    }

    private func rotationDidChange(from oldValue: Metric) {
        guard rotation != oldValue else {
            return
        }
        
        layer.rotation = rotation
        
        events.rotated.trigger()
    }

    private func autoResize() {
        guard shouldAutoResize else {
            return
        }

        let objCString = NSString(string: text)

        let rect = objCString.boundingRect(with: .zero,
                                           options: [.usesLineFragmentOrigin],
                                           attributes: [.font: font],
                                           context: nil)

        size = rect.size
    }

    private func horizontalAlignmentDidChange() {
        layer.alignmentMode = horizontalAlignment.mode
    }
}

public extension Label {
    enum HorizontalAlignment {
        case left
        case center
        case right
        case justified
    }
}

private extension Label.HorizontalAlignment {
    var mode: String {
        switch self {
        case .left:
            return kCAAlignmentLeft
        case .center:
            return kCAAlignmentCenter
        case .right:
            return kCAAlignmentRight
        case .justified:
            return kCAAlignmentJustified
        }
    }
}
