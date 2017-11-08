/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import QuartzCore

/**
 *  Class used to render a block of tiled textures
 *
 *  Blocks are non-active game objects (in that they can't be resized, transformed
 *  or have any events associated with them), that have the unique ability to render
 *  a collection of textures in a tiled way. You can assign up to 9 textures to a
 *  block, and it will automatically tile them to make it look nicely no matter which
 *  size the block itself is.
 *
 *  You specify the textures that a block should render using `BlockTextureCollection`,
 *  or you can simpy pass the name of such a collection when creating a block to have
 *  Imagine Engine automatically infer the names of all its parts.
 */
public final class Block: SceneObject, InstanceHashable, ActionPerformer, ZIndexed, Movable {
    /// The scene that the block currently belongs to
    public internal(set) var scene: Scene?
    /// The index of the block on the z axis. 0 = implicit index.
    public var zIndex = 0 { didSet { layer.zPosition = Metric(zIndex) } }
    /// The position (center-point) of the block within its scene.
    public var position = Point() { didSet { positionDidChange() } }
    /// The size of the block (centered on its position).
    public let size: Size
    /// The rectangle that the block currently occupies within its scene.
    public var rect: Rect { return layer.frame }
    /// Any logical group that the block is a part of. Can be used for events & collisions.
    public var group: Group?

    internal let layer = Layer()
    internal lazy var gridTiles = Set<Grid.Tile>()

    private let content: Content
    private let textureScale: Int?
    private lazy var actionManager = ActionManager(object: self)

    private init(size: Size, content: Content, textureScale: Int? = nil) {
        self.size = size
        self.content = content
        self.textureScale = textureScale

        layer.bounds.size = size
    }

    // MARK: - Public

    /// Remove this block from its scene
    public func remove() {
        scene?.remove(self)
    }

    // MARK: - ActionPerformer

    @discardableResult public func perform(_ action: Action<Block>) -> ActionToken {
        return actionManager.add(action)
    }

    // MARK: - Activatable

    internal func activate(in game: Game) {
        addSublayers(using: game.scene.textureManager)
        actionManager.activate(in: game)
    }

    internal func deactivate() {
        actionManager.deactivate()
        layer.removeFromSuperlayer()
    }

    // MARK: - Private

    private func addSublayers(using textureManager: TextureManager) {
        let segmentLayers: SegmentLayerCollection

        switch content {
        case .collection(let textures):
            segmentLayers = makeSegmentLayers(from: textures, using: textureManager)
        case .texture(let texture):
            guard let loadedTexture = textureManager.load(texture, namePrefix: nil, scale: textureScale) else {
                return
            }

            segmentLayers = makeSegmentLayers(from: loadedTexture)
        }

        layer.addSublayer(segmentLayers.top)
        layer.addSublayer(segmentLayers.bottom)

        segmentLayers.bottom.frame.origin.y = size.height - segmentLayers.bottom.frame.height

        let centerReplicatorLayer = ReplicatorLayer()
        centerReplicatorLayer.frame.origin.y = segmentLayers.top.frame.height
        centerReplicatorLayer.frame.size.width = size.width
        centerReplicatorLayer.frame.size.height = size.height - segmentLayers.top.frame.height - segmentLayers.bottom.frame.height
        centerReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, segmentLayers.center.frame.height, 0)
        centerReplicatorLayer.masksToBounds = true

        if segmentLayers.center.frame.height > 0 {
            centerReplicatorLayer.instanceCount = Int(ceil(centerReplicatorLayer.frame.height / segmentLayers.center.frame.height))
        }

        centerReplicatorLayer.addSublayer(segmentLayers.center)
        layer.addSublayer(centerReplicatorLayer)
    }

    private func makeSegmentLayers(from textures: BlockTextureCollection, using textureManager: TextureManager) -> SegmentLayerCollection {
        func loadTexture(_ texture: Texture?) -> LoadedTexture? {
            guard let texture = texture else {
                return nil
            }

            return textureManager.load(texture, namePrefix: nil, scale: textureScale)
        }

        let topSegmentLayer = SegmentLayer()
        topSegmentLayer.renderWithTextures(left: loadTexture(textures.topLeft),
                                           center: loadTexture(textures.top),
                                           right: loadTexture(textures.topRight),
                                           width: size.width)

        let bottomSegmentLayer = SegmentLayer()
        bottomSegmentLayer.renderWithTextures(left: loadTexture(textures.bottomLeft),
                                              center: loadTexture(textures.bottom),
                                              right: loadTexture(textures.bottomRight),
                                              width: size.width)

        let centerSegmentLayer = SegmentLayer()
        centerSegmentLayer.renderWithTextures(left: loadTexture(textures.left),
                                              center: loadTexture(textures.center),
                                              right: loadTexture(textures.right),
                                              width: size.width)

        return SegmentLayerCollection(
            top: topSegmentLayer,
            bottom: bottomSegmentLayer,
            center: centerSegmentLayer
        )
    }

    private func makeSegmentLayers(from texture: LoadedTexture) -> SegmentLayerCollection {
        let contentMetric: Metric = 1 / 3
        let contentSize = Size(width: contentMetric, height: contentMetric)

        func makeContentRect(withX x: Metric, y: Metric) -> Rect {
            return Rect(origin: Point(x: x, y: y), size: contentSize)
        }

        let contentRects = (
            top: makeContentRect(withX: contentMetric, y: 0),
            topLeft: makeContentRect(withX: 0, y: 0),
            topRight: makeContentRect(withX: contentMetric * 2, y: 0),
            left: makeContentRect(withX: 0, y: contentMetric),
            right: makeContentRect(withX: contentMetric * 2, y: contentMetric),
            center: makeContentRect(withX: contentMetric, y: contentMetric),
            bottom: makeContentRect(withX: contentMetric, y: contentMetric * 2),
            bottomLeft: makeContentRect(withX: 0, y: contentMetric * 2),
            bottomRight: makeContentRect(withX: contentMetric * 2, y: contentMetric * 2)
        )

        let topSegmentLayer = SegmentLayer()
        topSegmentLayer.renderWithTextures(
            left: texture,
            center: texture,
            right: texture,
            leftContentRect: contentRects.topLeft,
            centerContentRect: contentRects.top,
            rightContentRect: contentRects.topRight,
            width: size.width
        )

        let bottomSegmentLayer = SegmentLayer()
        bottomSegmentLayer.renderWithTextures(
            left: texture,
            center: texture,
            right: texture,
            leftContentRect: contentRects.bottomLeft,
            centerContentRect: contentRects.bottom,
            rightContentRect: contentRects.bottomRight,
            width: size.width
        )

        let centerSegmentLayer = SegmentLayer()
        centerSegmentLayer.renderWithTextures(
            left: texture,
            center: texture,
            right: texture,
            leftContentRect: contentRects.left,
            centerContentRect: contentRects.center,
            rightContentRect: contentRects.right,
            width: size.width
        )

        return SegmentLayerCollection(
            top: topSegmentLayer,
            bottom: bottomSegmentLayer,
            center: centerSegmentLayer
        )
    }

    private func positionDidChange() {
        layer.position = position
        scene?.blockRectDidChange(self)
    }
}

public extension Block {
    /// Initialize an instance of this class, with a given size and a collection of
    /// textures that it should render. You may also (optionally) choose which scale
    /// that the textures should be loaded using.
    convenience init(size: Size, textures: BlockTextureCollection, textureScale: Int? = nil) {
        self.init(size: size, content: .collection(textures), textureScale: textureScale)
    }

    /// Initialize an instance with a given size and the name of a texture collection
    /// See `BlockTextureCollection` for more information about how the names of
    /// individual textures are inferred.
    convenience init(size: Size, textureCollectionName: String, textureScale: Int? = nil, textureFormat: TextureFormat? = nil) {
        let textures = BlockTextureCollection(name: textureCollectionName, textureFormat: textureFormat)
        self.init(size: size, content: .collection(textures), textureScale: textureScale)
    }

    /// Initialize an instance with a given size and the name of a sprite sheet to use for
    /// the block's textures. The texture for the sprite sheet will be cut into 9 identically
    /// sized pieces (3 x 3), which will be used to tile the block.
    convenience init(size: Size, spriteSheetName: String, textureScale: Int? = nil, textureFormat: TextureFormat? = nil) {
        let texture = Texture(name: spriteSheetName, format: textureFormat)
        self.init(size: size, content: .texture(texture), textureScale: textureScale)
    }
}

private extension Block {
    enum Content {
        case texture(Texture)
        case collection(BlockTextureCollection)
    }

    final class SegmentLayer: CALayer {
        override func action(forKey event: String) -> CAAction? {
            return NSNull()
        }

        func renderWithTextures(left leftTexture: LoadedTexture?,
                                center centerTexture: LoadedTexture?,
                                right rightTexture: LoadedTexture?,
                                leftContentRect: Rect = .defaultContentRect,
                                centerContentRect: Rect = .defaultContentRect,
                                rightContentRect: Rect = .defaultContentRect,
                                width: Metric) {
            var leftLayerSize = Size()
            var rightLayerSize = Size()
            var centerLayerHeight: Metric = 0

            if let leftTexture = leftTexture {
                let leftLayer = makeContentLayer(withTexture: leftTexture, contentRect: leftContentRect)
                addSublayer(leftLayer)
                leftLayerSize = leftLayer.frame.size
            }

            if let rightTexture = rightTexture {
                let rightLayer = makeContentLayer(withTexture: rightTexture, contentRect: rightContentRect)
                rightLayer.frame.origin.x = width - rightLayer.frame.width
                addSublayer(rightLayer)
                rightLayerSize = rightLayer.frame.size
            }

            if let centerTexture = centerTexture {
                let centerContentLayer = makeContentLayer(withTexture: centerTexture, contentRect: centerContentRect)
                let centerTextureSize = centerContentLayer.frame.size
                
                let replicatorLayer = ReplicatorLayer()
                replicatorLayer.frame.size.width = width - leftLayerSize.width - rightLayerSize.width
                replicatorLayer.frame.size.height = centerTextureSize.height
                replicatorLayer.frame.origin.x = leftLayerSize.width
                replicatorLayer.instanceCount = Int(ceil(replicatorLayer.frame.width / centerTextureSize.width))
                replicatorLayer.instanceTransform = CATransform3DMakeTranslation(centerTextureSize.width, 0, 0)
                replicatorLayer.masksToBounds = true
                replicatorLayer.addSublayer(centerContentLayer)
                addSublayer(replicatorLayer)

                centerLayerHeight = replicatorLayer.frame.height
            }

            frame.size = Size(
                width: width,
                height: max(leftLayerSize.height, rightLayerSize.height, centerLayerHeight)
            )
        }

        private func makeContentLayer(withTexture texture: LoadedTexture, contentRect: Rect) -> CALayer {
            let layer = Layer()
            layer.contents = texture.image
            layer.contentsRect = contentRect
            layer.frame.size.width = texture.size.width * contentRect.size.width
            layer.frame.size.height = texture.size.height * contentRect.size.height
            return layer
        }
    }

    final class ReplicatorLayer: CAReplicatorLayer {
        override func action(forKey event: String) -> CAAction? {
            return NSNull()
        }
    }

    struct SegmentLayerCollection {
        let top: SegmentLayer
        let bottom: SegmentLayer
        let center: SegmentLayer
    }
}

private extension Rect {
    static let defaultContentRect = Rect(x: 0, y: 0, width: 1, height: 1)
}
