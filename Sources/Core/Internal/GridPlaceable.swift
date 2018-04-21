import Foundation

internal protocol GridPlaceable: AnyObject {
    var gridTiles: Set<Grid.Tile> { get }

    func add(to gridTile: Grid.Tile)
    func remove(from gridTile: Grid.Tile)
}
