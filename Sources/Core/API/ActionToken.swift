import Foundation

/**
 *  Token returned when an action was performed
 *
 *  You can use an action token to either cancel an action, or to observe when
 *  it was finished. You can also use it to chain an ongoing action to another
 *  one, making it automatically performed once the current action has finished.
 *
 *  Here's an example of how to cancel an action:
 *
 *  ```
 *  let token = actor.move(byX: 50, y: 300, duration: 5)
 *  token.cancel()
 *  ```
 *
 *  Here's how you can run a closure whenever an action was finished:
 *
 *  ```
 *  actor.move(byX: 50, y: 300, duration: 5).then {
 *      print("Move finished!")
 *  }
 *  ```
 *
 *  Here's how an action can be chained into another:
 *
 *  ```
 *  actor.move(byX: 50, y: 300, duration: 5)
 *       .then(actor.fadeOut(withDuration: 3))
 *  ```
 *
 *  Finally, here's how two actions can be linked togher to be performed at the same time:
 *
 *  ```
 *  actor.move(byX: 50, y: 300, duration: 5)
 *       .also(actor.fadeOut(withDuration: 3))
 *  ```
 */
public final class ActionToken: CancellationToken {
    internal private(set) lazy var linkedTokens = [ActionToken]()
    internal private(set) lazy var chain = [ChainItem]()
    internal var isPending = false

    /// Link the action that this token is for to another one
    /// You can use this API to perform two actions in parallel
    @discardableResult public func also(_ token: ActionToken) -> ActionToken {
        token.isPending = true
        linkedTokens.append(token)
        return token
    }

    /// Chain the action that this token is for to another one
    /// You can use this API to perform two actions in sequence
    @discardableResult public func then(_ token: ActionToken) -> ActionToken {
        token.isPending = true
        chain.append(.token(token))
        return token
    }

    /// Run any function after the action that this token is for has finished
    @discardableResult public func then(_ closure: @escaping @autoclosure () -> Void) -> ActionToken {
        chain.append(.closure(closure))
        return self
    }

    /// Run any closure after the action that this token is for has finished
    @discardableResult public func then(_ closure: @escaping () -> Void) -> ActionToken {
        chain.append(.closure(closure))
        return self
    }

    // MARK: - Internal

    internal func performChaining() {
        for item in chain {
            switch item {
            case .token(let token):
                token.isPending = false
            case .closure(let closure):
                closure()
            }
        }
    }
}

internal extension ActionToken {
    enum ChainItem {
        case token(ActionToken)
        case closure(() -> Void)
    }
}
