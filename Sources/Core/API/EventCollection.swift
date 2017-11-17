/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class that defines a collection of events
 *
 *  Events are used to drive most of the game logic in an Imagine Engine
 *  game. Objects like Actors and Scenes define an event collection that
 *  both comes with built-in events, and enables you to define your own.
 */
public class EventCollection<Object: AnyObject> {
    internal private(set) weak var object: Object?
    private lazy var events = [String : AnyObject]()

    internal init(object: Object) {
        self.object = object
    }

    /// Make a new event with an identifier for the event's subject
    /// Call this method within an extension defining a custom event.
    /// For more information, see the documentation for `Event`.
    public func makeEvent<Subject>(named name: StaticString = #function,
                                   withSubjectIdentifier subjectIdentifier: String) -> Event<Object, Subject> {
        let name = "\(name)-\(subjectIdentifier)"

        if let event = events[name] {
            // swiftlint:disable:next force_cast
            return event as! Event<Object, Subject>
        }

        let event = Event<Object, Subject>(object: object)
        events[name] = event
        return event
    }

    /// Make a new event with a subject
    /// Call this method within an extension defining a custom event.
    /// For more information, see the documentation for `Event`.
    public func makeEvent<Subject: AnyObject>(named name: StaticString = #function,
                                              withSubject subject: Subject) -> Event<Object, Subject> {
        return makeEvent(named: name, withSubjectIdentifier: String(describing: ObjectIdentifier(subject)))
    }

    /// Make a new event that is not bound to a specific subject
    /// Call this method within an extension defining a custom event.
    /// For more information, see the documentation for `Event`.
    public func makeEvent<Subject>(named name: StaticString = #function) -> Event<Object, Subject> {
        return makeEvent(named: name, withSubjectIdentifier: "Void")
    }
}
