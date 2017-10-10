/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
import ImagineEngine

final class ActionTests: XCTestCase {
    private var game: GameMock!

    override func setUp() {
        super.setUp()
        game = GameMock()
    }

    func testPerformingAction() {
        let actor = Actor()
        game.scene.add(actor)

        let action = ActionMock<Actor>(duration: 4)
        actor.perform(action)

        // After the first update the action should have been started
        game.update()
        XCTAssertTrue(action.isStarted)
        XCTAssertEqual(action.context?.completionRatio, 0)
        assertSameInstance(action.object, actor)
        assertSameInstance(action.object, action.context?.object)

        // At this point the action should be mid-way
        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(action.context?.completionRatio, 0.5)
        XCTAssertEqual(action.context?.timeElapsed, 2)
        XCTAssertEqual(action.context?.timeSinceLastUpdate, 2)

        // At this point the action should be finished
        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(action.context?.completionRatio, 1)
        XCTAssertEqual(action.context?.timeElapsed, 4)
        XCTAssertEqual(action.context?.timeSinceLastUpdate, 2)
        XCTAssertTrue(action.isFinished)
    }

    func testCancellingAction() {
        let actor = Actor()
        game.scene.add(actor)

        let action = ActionMock<Actor>(duration: 4)
        let token = actor.perform(action)
        game.update()
        XCTAssertTrue(action.isStarted)

        token.cancel()
        game.update()
        XCTAssertTrue(action.isCancelled)

        // After being cancelled the action should not receive more updates
        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(action.context?.completionRatio, 0)
    }
}
