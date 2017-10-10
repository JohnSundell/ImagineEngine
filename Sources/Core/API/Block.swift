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
public final class Block: InstanceHashable, Activatable, ActionPerformer, Movable {
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

    private let textures: BlockTextureCollection
    private let textureScale: Int?
    private lazy var actionManager = ActionManager(object: self)

    /// Initialize an instance of this class, with a given size and a collection of
    /// textures that it should render. You may also (optionally) choose which scale
    /// that the textures should be loaded using.
    public init(size: Size, textures: BlockTextureCollection, textureScale: Int? = nil) {
        self.size = size
        self.textures = textures
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
    }

    // MARK: - Private

    private func addSublayers(using textureManager: TextureManager) {
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
        layer.addSublayer(topSegmentLayer)

        let bottomSegmentLayer = SegmentLayer()
        bottomSegmentLayer.renderWithTextures(left: loadTexture(textures.bottomLeft),
                                              center: loadTexture(textures.bottom),
                                              right: loadTexture(textures.bottomRight),
                                              width: size.width)
        bottomSegmentLayer.frame.origin.y = size.height - bottomSegmentLayer.frame.height
        layer.addSublayer(bottomSegmentLayer)

        let centerSegmentLayer = SegmentLayer()
        centerSegmentLayer.renderWithTextures(left: loadTexture(textures.left),
                                              center: loadTexture(textures.center),
                                              right: loadTexture(textures.right),
                                              width: size.width)

        let centerReplicatorLayer = ReplicatorLayer()
        centerReplicatorLayer.frame.origin.y = topSegmentLayer.frame.height
        centerReplicatorLayer.frame.size.width = size.width
        centerReplicatorLayer.frame.size.height = size.height - topSegmentLayer.frame.height - bottomSegmentLayer.frame.height
        centerReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, centerSegmentLayer.frame.height, 0)

        if centerSegmentLayer.frame.height > 0 {
            centerReplicatorLayer.instanceCount = Int(ceil(centerReplicatorLayer.frame.height / centerSegmentLayer.frame.height))
        }

        centerReplicatorLayer.addSublayer(centerSegmentLayer)
        layer.addSublayer(centerReplicatorLayer)
    }

    private func positionDidChange() {
        layer.position = position
        scene?.blockRectDidChange(self)
    }
}

public extension Block {
    /// Initialize a block with a given size and the name of a texture collection
    /// See `BlockTextureCollection` for more information about how the names of
    /// individual textures are inferred.
    convenience init(size: Size, textureCollectionName: String) {
        let textures = BlockTextureCollection(name: textureCollectionName)
        self.init(size: size, textures: textures)
    }
}

private extension Block {
    final class SegmentLayer: CALayer {
        override func action(forKey event: String) -> CAAction? {
            return NSNull()
        }

        func renderWithTextures(left leftTexture: LoadedTexture?,
                                center centerTexture: LoadedTexture?,
                                right rightTexture: LoadedTexture?,
                                width: Metric) {
            var leftLayerSize = Size()
            var rightLayerSize = Size()
            var centerLayerHeight: Metric = 0

            if let leftTexture = leftTexture {
                let leftLayer = makeContentLayer(withTexture: leftTexture)
                addSublayer(leftLayer)
                leftLayerSize = leftLayer.frame.size
            }

            if let rightTexture = rightTexture {
                let rightLayer = makeContentLayer(withTexture: rightTexture)
                rightLayer.frame.origin.x = width - rightLayer.frame.width
                addSublayer(rightLayer)
                rightLayerSize = rightLayer.frame.size
            }

            if let centerTexture = centerTexture {
                let replicatorLayer = ReplicatorLayer()
                replicatorLayer.frame.size.width = width - leftLayerSize.width - rightLayerSize.width
                replicatorLayer.frame.size.height = centerTexture.size.height
                replicatorLayer.frame.origin.x = leftLayerSize.width
                replicatorLayer.instanceCount = Int(ceil(replicatorLayer.frame.width / centerTexture.size.width))
                replicatorLayer.instanceTransform = CATransform3DMakeTranslation(centerTexture.size.width, 0, 0)
                addSublayer(replicatorLayer)

                let centerContentLayer = makeContentLayer(withTexture: centerTexture)
                replicatorLayer.addSublayer(centerContentLayer)

                centerLayerHeight = replicatorLayer.frame.height
            }

            frame.size = Size(
                width: width,
                height: max(leftLayerSize.height, rightLayerSize.height, centerLayerHeight)
            )
        }

        private func makeContentLayer(withTexture texture: LoadedTexture) -> CALayer {
            let layer = Layer()
            layer.contents = texture.image
            layer.frame.size = texture.size
            return layer
        }
    }

    final class ReplicatorLayer: CAReplicatorLayer {
        override func action(forKey event: String) -> CAAction? {
            return NSNull()
        }
    }
}
