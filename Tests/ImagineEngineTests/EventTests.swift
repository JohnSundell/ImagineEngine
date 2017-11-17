/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation
import XCTest
import ImagineEngine

private extension EventCollection where Object == Actor {
    var testEvent: Event<Actor, Point> {
        return makeEvent(withSubjectIdentifier: "subject")
    }

    var testEventWithoutSubjectIdentifier: Event<Actor, Size> {
        return makeEvent()
    }
}

final class EventTests: XCTestCase {
    func testMakingAndObservingEvent() {
        let actor = Actor()
        let event = actor.events.testEvent

        // Accessing the event again should return the same instance
        assertSameInstance(event, actor.events.testEvent)

        var observedActor: Actor?
        var observedPoint: Point?

        event.observe {
            observedActor = $0
            observedPoint = $1
        }

        event.trigger(with: Point(x: 200, y: 100))
        assertSameInstance(observedActor, actor)
        XCTAssertEqual(observedPoint, Point(x: 200, y: 100))
    }

    func testMakingAndObservingEventWithoutSubjectIdentifier() {
        let actor = Actor()
        let event = actor.events.testEventWithoutSubjectIdentifier

        // Accessing the event again should return the same instance
        assertSameInstance(event, actor.events.testEventWithoutSubjectIdentifier)

        var observedActor: Actor?
        var observedSize: Size?

        event.observe {
            observedActor = $0
            observedSize = $1
        }

        event.trigger(with: Size(width: 200, height: 100))
        assertSameInstance(observedActor, actor)
        XCTAssertEqual(observedSize, Size(width: 200, height: 100))
    }

    func testAddingAndRemovingObserver() {
        let observer = Actor()
        let actor = Actor()

        var passedObserver: Actor?
        var passedActor: Actor?
        var triggerCount = 0

        actor.events.resized.addObserver(observer) {
            passedObserver = $0
            passedActor = $1
            triggerCount += 1
        }

        actor.events.resized.trigger()
        assertSameInstance(passedObserver, observer)
        assertSameInstance(passedActor, actor)
        XCTAssertEqual(triggerCount, 1)

        actor.events.resized.removeObserver(observer)
        actor.events.resized.trigger()
        XCTAssertEqual(triggerCount, 1)
    }

    func testObserversNotRetained() {
        var observer: Actor? = Actor()
        weak var weakObserver = observer

        let actor = Actor()
        var triggerCount = 0

        actor.events.resized.addObserver(observer!) { _ in
            triggerCount += 1
        }

        actor.events.resized.trigger()
        XCTAssertEqual(triggerCount, 1)

        observer = nil
        XCTAssertNil(weakObserver)

        actor.events.resized.trigger()
        XCTAssertEqual(triggerCount, 1)
    }

    func testCancellingObservationUsingToken() {
        let actor = Actor()
        var triggerCount = 0

        let token = actor.events.resized.observe {
            triggerCount += 1
        }

        actor.events.resized.trigger()
        XCTAssertEqual(triggerCount, 1)

        token.cancel()
        actor.events.resized.trigger()
        XCTAssertEqual(triggerCount, 1)
    }
}
