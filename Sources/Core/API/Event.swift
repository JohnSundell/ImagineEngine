/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class that represents an event that can occur in a game
 *
 *  You use this class to observe and trigger events that can happen
 *  in your game, and is the recommended way to drive most of your
 *  game logic.
 *
 *  To observe an event, simply call the `observe` method on it:
 *
 *  ```
 *  actor.events.moved.observe { actor in
 *      print("This actor was moved: \(actor)")
 *  }
 *  ```
 *
 *  To define a custom event, create an extension on `EventCollection`
 *  that defines a computed property for your event, and simply call
 *  `makeEvent()` within its implementation, like this:
 *
 *  ```
 *  extension EventCollection where Object == Actor {
 *      var myEvent: Event<Actor, Void> {
 *          return makeEvent()
 *      }
 *  }
 *  ```
 *
 *  You can then trigger the event like this:
 *
 *  ```
 *  actor.events.myEvent.trigger()
 *  ```
 */
public final class Event<Object: AnyObject, Subject> {
    private weak var object: Object?
    private lazy var observations = [ObservationKey : Observation]()

    // MARK: - Initializer

    internal init(object: Object?) {
        self.object = object
    }

    // MARK: - Public

    /// Trigger the event with a subject value
    /// A subject is the object or value that the event happened with, for
    /// example in a collision the subject will be the object collided with.
    public func trigger(with subject: Subject) {
        guard let object = object else {
            return
        }

        for (key, observation) in observations {
            switch key {
            case .objectIdentifier:
                break
            case .token(let token):
                guard !token.isCancelled else {
                    observations[key] = nil
                    continue
                }
            }

            observation.closure(object, subject)
        }
    }

    /// Observe the event using a closure
    @discardableResult public func observe(using closure: @escaping (Object, Subject) -> Void) -> EventToken {
        let token = EventToken()
        observations[.token(token)] = Observation(closure: closure)
        return token
    }

    /// Add an observer to the event, that will be passed into the observation closure
    public func addObserver<T: AnyObject>(_ observer: T, closure: @escaping (T, Object, Subject) -> Void) {
        let identifier = ObjectIdentifier(observer)

        observations[.objectIdentifier(identifier)] = Observation { [weak self, weak observer] object, subject in
            guard let observer = observer else {
                self?.observations[.objectIdentifier(identifier)] = nil
                return
            }

            closure(observer, object, subject)
        }
    }

    /// Remove an observer from the event
    public func removeObserver<T: AnyObject>(_ observer: T) {
        let identifier = ObjectIdentifier(observer)
        observations[.objectIdentifier(identifier)] = nil
    }
}

public extension Event {
    /// Observe the event using a closure that only gets passed the event's object
    @discardableResult func observe(using closure: @escaping (Object) -> Void) -> EventToken {
        return observe { object, _ in
            closure(object)
        }
    }

    /// Observe the event using a closure that doesn't take any arguments
    @discardableResult func observe(using closure: @escaping () -> Void) -> EventToken {
        return observe { _, _ in
            closure()
        }
    }

    /// Add an observer to the event using a closure that only gets passed the event's object
    func addObserver<T: AnyObject>(_ observer: T, closure: @escaping (T, Object) -> Void) {
        addObserver(observer) { observer, object, _ in
            closure(observer, object)
        }
    }

    /// Add an observer to the event using a closure that only gets passed the observer
    func addObserver<T: AnyObject>(_ observer: T, closure: @escaping (T) -> Void) {
        addObserver(observer) { observer, _, _ in
            closure(observer)
        }
    }
}

public extension Event where Subject == Void {
    /// Trigger a Void-based event without a subject
    func trigger() {
        trigger(with: Void())
    }
}

private extension Event {
    enum ObservationKey {
        case token(EventToken)
        case objectIdentifier(ObjectIdentifier)
    }

    struct Observation {
        let closure: (Object, Subject) -> Void
    }
}

extension Event.ObservationKey: Hashable {
    static func ==(lhs: Event.ObservationKey, rhs: Event.ObservationKey) -> Bool {
        switch lhs {
        case .token(let tokenA):
            switch rhs {
            case .token(let tokenB):
                return tokenA === tokenB
            case .objectIdentifier:
                return false
            }
        case .objectIdentifier(let identifierA):
            switch rhs {
            case .token:
                return false
            case .objectIdentifier(let identifierB):
                return identifierA == identifierB
            }
        }
    }

    var hashValue: Int {
        switch self {
        case .objectIdentifier(let identifier):
            return identifier.hashValue
        case .token(let token):
            return ObjectIdentifier(token).hashValue
        }
    }
}
