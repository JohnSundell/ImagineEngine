/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

/**
 *  Class that can be used to execute code later at various points in the future
 *
 *  Since Imagine Engine games are updated based on the frame rate of the screen
 *  that they are being rendered on, and since they can be paused at any time, it's
 *  not recommended to use DispatchQueue, NSTimer or other APIs to dispatch code
 *  at a future point. Instead, use this class.
 *
 *  Each Imagine Engine scene comes with a timeline that it uses to perform all of
 *  it's internal delayed events. You can also attach your own code to a timeline
 *  to be executed at a future point.
 *
 *  Here's an example of how a closure can be attached to a timeline to be executed
 *  5 seconds later:
 *
 *  ```
 *  scene.timeline.after(interval: 5) {
 *      print("5 seconds later!")
 *  }
 *  ```
 *
 *  Every time you schedule a closure with a timeline, you get a cancellation token
 *  back, that can be used to cancel the closure at any time before it has been run.
 */
public final class Timeline: Activatable {
    internal var isPaused = false

    private var rootNode: Node?
    private lazy var unsortedUpdatables = [(UpdatableWrapper, TimeInterval)]()
    private lazy var immediateUpdatables = UpdatableCollection()
    private var lastUpdateTime: TimeInterval?
    private var pauseInterval: TimeInterval = 0

    /// Run a closure once after a given time interval
    @discardableResult public func after(interval: TimeInterval,
                                         run closure: @escaping () -> Void) -> CancellationToken {
        let updatable = ClosureUpdatable(closure: closure)
        return schedule(updatable, delay: interval)
    }

    /// Repeat a closure by a given time interval, until it's cancelled by the returned token
    @discardableResult public func `repeat`(withInterval interval: TimeInterval,
                                            mode: RepeatMode = .forever,
                                            closure: @escaping () -> Void) -> CancellationToken {
        let updatable = ClosureUpdatable(repeatMode: mode) { () -> UpdateOutcome in
            closure()
            return .continueAfter(interval)
        }

        return schedule(updatable, delay: interval)
    }

    internal func schedule(_ updatable: UpdatableWrapper, delay: TimeInterval) {
        guard delay > 0 else {
            immediateUpdatables.insert(updatable)
            return
        }

        guard let lastUpdateTime = lastUpdateTime else {
            unsortedUpdatables.append((updatable, delay))
            return
        }

        insert(updatable, at: lastUpdateTime + delay - pauseInterval)
    }

    internal func update(currentTime: TimeInterval) {
        if isPaused {
            if let lastUpdateTime = lastUpdateTime {
                pauseInterval += currentTime - lastUpdateTime
            }
        }

        lastUpdateTime = currentTime
        let currentTime = currentTime - pauseInterval

        for updatable in immediateUpdatables.removeAll() {
            let outcome = updatable.update(currentTime: currentTime)

            switch outcome {
            case .continueAfter(let delay):
                schedule(updatable, delay: delay)
            case .finished:
                break
            }
        }

        if let root = rootNode {
            let outcome = root.update(in: self, currentTime: currentTime)

            switch outcome {
            case .keep:
                break
            case .discard:
                rootNode = rootNode?.greaterChild
            }
        }
    }

    // MARK: - Activatable

    func activate(in game: Game) {
        lastUpdateTime = game.currentTime

        for (updatable, delay) in unsortedUpdatables {
            insert(updatable, at: game.currentTime + delay)
        }
    }

    // MARK: - Private

    private func insert(_ updatable: UpdatableWrapper, at time: TimeInterval) {
        guard let root = rootNode else {
            rootNode = Node(time: time, updatable: updatable)
            return
        }

        root.insert(updatable, at: time)
    }

    private func schedule(_ updatable: ClosureUpdatable, delay: TimeInterval) -> CancellationToken {
        let wrapper = UpdatableWrapper(updatable: updatable)
        schedule(wrapper, delay: delay)
        return wrapper.cancellationToken
    }
}

private extension Timeline {
    final class Node {
        let time: TimeInterval
        var updatables = UpdatableCollection()
        var greaterChild: Node?
        var lesserChild: Node?

        init(time: TimeInterval, updatable: UpdatableWrapper) {
            self.time = time
            updatables.insert(updatable)
        }

        func insert(_ updatable: UpdatableWrapper, at insertTime: TimeInterval) {
            if insertTime == time {
                updatables.insert(updatable)
            } else if insertTime > time {
                if let greaterChild = greaterChild {
                    greaterChild.insert(updatable, at: insertTime)
                } else {
                    greaterChild = Node(time: insertTime, updatable: updatable)
                }
            } else {
                if let lesserChild = lesserChild {
                    lesserChild.insert(updatable, at: insertTime)
                } else {
                    lesserChild = Node(time: insertTime, updatable: updatable)
                }
            }
        }

        func update(in timeline: Timeline, currentTime: TimeInterval) -> NodeUpdateOutcome {
            if currentTime >= time {
                for updatable in updatables.removeAll() {
                    let outcome = updatable.update(currentTime: currentTime)

                    switch outcome {
                    case .continueAfter(let delay):
                        timeline.schedule(updatable, delay: delay)
                    case .finished:
                        break
                    }
                }
            }

            if currentTime > time {
                if let child = greaterChild {
                    let outcome = child.update(in: timeline, currentTime: currentTime)

                    switch outcome {
                    case .keep:
                        break
                    case .discard:
                        greaterChild = greaterChild?.greaterChild
                    }
                }
            }

            if let child = lesserChild {
                let outcome = child.update(in: timeline, currentTime: currentTime)

                switch outcome {
                case .keep:
                    break
                case .discard:
                    lesserChild = lesserChild?.greaterChild
                }
            }

            return updatables.isEmpty ? .discard : .keep
        }
    }

    enum NodeUpdateOutcome {
        case keep
        case discard
    }
}

public extension Timeline {
    /// Run a closure after a given time interval, using an object that will be passed into the closure when run.
    /// The object won't be retained, and if it's released before the interval has passed, the closure won't be run.
    @discardableResult func after<T: AnyObject>(interval: TimeInterval,
                                                using object: T,
                                                run closure: @escaping (T) -> Void) -> CancellationToken {
        return after(interval: interval) { [weak object] in
            object.map(closure)
        }
    }

    /// Repeat a closure by a given time interval, using an object that will be passed into the closure when run.
    /// The closure will be repeated until either its object is released, or until cancelled using the returned token.
    @discardableResult func `repeat`<T: AnyObject>(withInterval interval: TimeInterval,
                                                   using object: T,
                                                   mode: RepeatMode = .forever,
                                                   closure: @escaping (T) -> Void) -> CancellationToken {
        let updatable = ClosureUpdatable(repeatMode: mode) { [weak object] () -> UpdateOutcome in
            guard let object = object else {
                return .finished
            }

            closure(object)
            return .continueAfter(interval)
        }

        return schedule(updatable, delay: interval)
    }
}
