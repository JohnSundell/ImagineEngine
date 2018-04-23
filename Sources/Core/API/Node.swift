import Foundation
import QuartzCore

/// Base class for node objects that make up the hierarchy of a scene
/// Usually you use one of the subclass implementations of this class,
/// such as Actor, Block or Label.
open class Node<Layer: CALayer>: AnyNode {
    /// The scene that the node currently belongs to.
    public internal(set) weak var scene: Scene?
    /// The rectangle that the node currently occupies within its scene.
    public var rect: Rect { return layer.frame }

    internal let layer: Layer
    internal var gridTiles = Set<Grid.Tile>()

    public init(layer: Layer) {
        self.layer = layer
    }
}
