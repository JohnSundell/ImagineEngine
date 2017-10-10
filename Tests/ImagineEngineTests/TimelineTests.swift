/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
import ImagineEngine

final class TimelineTests: XCTestCase {
    private var game: GameMock!

    override func setUp() {
        super.setUp()
        game = GameMock()
    }

    func testRunningClosureAfterInterval() {
        var runCount = 0

        game.scene.timeline.after(interval: 3) {
            runCount += 1
        }

        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(runCount, 0)

        game.timeTraveler.travel(by: 1)
        game.update()
        XCTAssertEqual(runCount, 1)

        // The closure should only be run once
        game.timeTraveler.travel(by: 3)
        game.update()
        XCTAssertEqual(runCount, 1)
    }

    func testRepeatingClosureUntilCancelled() {
        var runCount = 0

        let token = game.scene.timeline.repeat(withInterval: 3) {
            runCount += 1
        }

        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(runCount, 0)

        game.timeTraveler.travel(by: 1)
        game.update()
        XCTAssertEqual(runCount, 1)

        game.timeTraveler.travel(by: 3)
        game.update()
        XCTAssertEqual(runCount, 2)

        game.timeTraveler.travel(by: 3)
        game.update()
        XCTAssertEqual(runCount, 3)

        token.cancel()
        game.timeTraveler.travel(by: 3)
        game.update()
        XCTAssertEqual(runCount, 3)
    }
}
