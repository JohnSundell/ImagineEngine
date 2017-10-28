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

    func testChainingMultipleActions() {
        let actionA = ActionMock<Actor>(duration: 2)
        let actionB = ActionMock<Actor>(duration: 3)
        let actionC = ActionMock<Actor>(duration: 4)

        let actor = Actor()
        game.scene.add(actor)

        var allActionsFinished = false

        actor.perform(actionA)
             .then(actor.perform(actionB))
             .then(actor.perform(actionC))
             .then {
                 allActionsFinished = true
             }

        // Start the first action
        game.update()
        XCTAssertTrue(actionA.isStarted)
        XCTAssertFalse(actionB.isStarted)
        XCTAssertFalse(actionC.isStarted)
        XCTAssertFalse(allActionsFinished)

        // After 1 second only the first action should be 50% complete
        game.timeTraveler.travel(by: 1)
        game.update()
        XCTAssertEqual(actionA.context?.completionRatio, 0.5)
        XCTAssertNil(actionB.context)
        XCTAssertNil(actionC.context)

        // After 2 seconds, the first action should be finished and the second started
        game.timeTraveler.travel(by: 1)
        game.update()
        XCTAssertTrue(actionA.isFinished)
        XCTAssertTrue(actionB.isStarted)
        XCTAssertFalse(actionC.isStarted)
        XCTAssertFalse(allActionsFinished)

        // After 3.5 seconds, the second action should be 50% complete
        game.timeTraveler.travel(by: 1.5)
        game.update()
        XCTAssertEqual(actionB.context?.completionRatio, 0.5)
        XCTAssertNil(actionC.context)

        // After 5 seconds, the second action should be finished and the third started
        game.timeTraveler.travel(by: 1.5)
        game.update()
        XCTAssertTrue(actionB.isFinished)
        XCTAssertTrue(actionC.isStarted)
        XCTAssertFalse(allActionsFinished)

        // After 9 seconds all actions should be completed
        game.timeTraveler.travel(by: 4)
        game.update()
        XCTAssertTrue(actionA.isFinished)
        XCTAssertTrue(actionB.isFinished)
        XCTAssertTrue(actionC.isFinished)
        XCTAssertTrue(allActionsFinished)
    }

    func testCancellingChainedActions() {
        let actionA = ActionMock<Actor>(duration: 2)
        let actionB = ActionMock<Actor>(duration: 3)
        let actionC = ActionMock<Actor>(duration: 4)

        let actor = Actor()
        game.scene.add(actor)

        let token = actor.perform(actionA)
                         .then(actor.perform(actionB))
                         .then(actor.perform(actionC))

        game.update()
        XCTAssertTrue(actionA.isStarted)
        XCTAssertFalse(actionB.isStarted)
        XCTAssertFalse(actionC.isStarted)

        // Cancelling at this point should only send the cancel event to the first action
        token.cancel()
        game.update()
        XCTAssertTrue(actionA.isCancelled)
        XCTAssertFalse(actionB.isCancelled)
        XCTAssertFalse(actionC.isCancelled)

        // None of the actions should receive any updates after being cancelled
        game.timeTraveler.travel(by: 1)
        game.update()
        game.timeTraveler.travel(by: 2)
        game.update()
        game.timeTraveler.travel(by: 1)
        game.update()
        game.timeTraveler.travel(by: 2)
        game.update()

        XCTAssertEqual(actionA.context?.completionRatio, 0)
        XCTAssertNil(actionB.context)
        XCTAssertNil(actionC.context)
    }
}
