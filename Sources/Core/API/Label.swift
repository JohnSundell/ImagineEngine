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
public final class Label: SceneObject, InstanceHashable, ActionPerformer, ZIndexed, Movable, Fadeable {
    /// The scene that the label currently belongs to.
    public internal(set) var scene: Scene?
    /// The index of the label on the z axis. Affects rendering. 0 = implicit index.
    public var zIndex = 0 { didSet { layer.zPosition = Metric(zIndex) } }
    /// The position of the label within its scene.
    public var position = Point() { didSet { layer.position = position } }
    /// The size of the label, centered on its position.
    public var size = Size() { didSet { layer.bounds.size = size } }
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
    private lazy var actionManager = ActionManager(object: self)

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

    // MARK: - ActionPerformer

    @discardableResult public func perform(_ action: Action<Label>) -> ActionToken {
        return actionManager.add(action)
    }

    // MARK: - Activatable

    internal func activate(in game: Game) {
        actionManager.activate(in: game)
    }

    internal func deactivate() {
        actionManager.deactivate()
        layer.removeFromSuperlayer()
    }

    // MARK: - Public

    /// Remove the label from its scene
    public func remove() {
        scene?.remove(self)
    }

    // MARK: - Private

    private func textDidChange() {
        layer.string = text
        autoResize()
    }

    private func fontDidChange() {
        layer.font = font
        layer.fontSize = font.pointSize
        autoResize()
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
