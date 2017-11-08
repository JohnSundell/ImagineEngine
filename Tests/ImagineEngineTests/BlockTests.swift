import Foundation
import XCTest
@testable import ImagineEngine

final class BlockTests: XCTestCase {
    private var block: Block!
    private var game: GameMock!

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()
        block = Block(size: .zero, spriteSheetName: "SpriteSheet")
        game = GameMock()
        game.scene.add(block)
    }

    // MARK: - Tests

    func testLayerAndSceneReferenceRemovedWhenBlockIsRemoved() {
        XCTAssertNotNil(block.layer.superlayer)
        XCTAssertNotNil(block.scene)

        block.remove()
        XCTAssertNil(block.layer.superlayer)
        XCTAssertNil(block.scene)
    }
}
