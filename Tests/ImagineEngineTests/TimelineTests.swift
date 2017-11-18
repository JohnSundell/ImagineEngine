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

    func testRunningClosureAfterIntervalWithObject() {
        var actor = Actor()
        weak var passedActor: Actor?

        game.scene.timeline.after(interval: 2, using: actor) { actor in
            passedActor = actor
        }

        game.timeTraveler.travel(by: 2)
        game.update()
        assertSameInstance(actor, passedActor)

        // Make sure the object is not retained by the timeline
        actor = Actor()
        XCTAssertNil(passedActor)
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

    func testRepeatingClosureWithObject() {
        var actor = Actor()
        weak var passedActor: Actor?

        game.scene.timeline.repeat(withInterval: 2, using: actor) { actor in
            passedActor = actor
        }

        game.timeTraveler.travel(by: 2)
        game.update()
        assertSameInstance(actor, passedActor)

        // Make sure the object is not retained by the timeline
        actor = Actor()
        XCTAssertNil(passedActor)
    }

    func testRepeatingClosureASetNumberOfTimes() {
        var runCount = 0

        game.scene.timeline.repeat(withInterval: 2, mode: .times(2)) {
            runCount += 1
        }

        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(runCount, 1)

        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(runCount, 2)

        // The third time the event shouldn't be repeated anymore
        game.timeTraveler.travel(by: 2)
        game.update()
        XCTAssertEqual(runCount, 2)
    }

    func testScheduledClosureNotRetained() {
        var actor = Actor()
        weak var weakActor = actor

        game.scene.timeline.after(interval: 2) {
            // Capture the actor as a strong reference
            actor.backgroundColor = .red
        }

        game.timeTraveler.travel(by: 2)
        game.update()

        // The closure should now have been removed, and the actor shouldn't be retained
        actor = Actor()
        XCTAssertNil(weakActor)
    }

    func testRepeatedClosureNotRetained() {
        var actor = Actor()
        weak var weakActor = actor

        game.scene.timeline.repeat(withInterval: 2, mode: .times(2)) {
            // Capture the actor as a strong reference
            actor.backgroundColor = .red
        }

        game.timeTraveler.travel(by: 2)
        game.update()
        game.timeTraveler.travel(by: 2)
        game.update()

        // The closure should now have been removed, and the actor shouldn't be retained
        actor = Actor()
        XCTAssertNil(weakActor)
    }
}
