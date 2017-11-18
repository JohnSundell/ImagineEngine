/**
 *  Imagine Engine
 *  Copyright (c) John Sundell 2017
 *  See LICENSE file for license
 */

import Foundation

internal struct UpdatableCollection {
    var isEmpty: Bool { return firstNode == nil }

    private var firstNode: Node?
    private var lastNode: Node?
    private var allNodes = [ObjectIdentifier : Node]()

    mutating func insert(_ object: UpdatableWrapper) {
        let identifier = ObjectIdentifier(object)

        guard allNodes[identifier] == nil else {
            return
        }

        let node = Node(object: object)
        allNodes[identifier] = node

        if let parentNode = lastNode {
            parentNode.next = node
            node.previous = parentNode
            lastNode = node
        } else {
            firstNode = node
            lastNode = node
        }
    }

    mutating func remove(_ object: UpdatableWrapper) {
        let identifier = ObjectIdentifier(object)

        guard let node = allNodes.removeValue(forKey: identifier) else {
            return
        }

        node.next?.previous = node.previous
        node.previous?.next = node.next

        if node === firstNode {
            firstNode = node.next
        }

        if node === lastNode {
            lastNode = node.previous
        }
    }
}

extension UpdatableCollection: Sequence {
    struct Iterator: IteratorProtocol {
        fileprivate var node: Node?

        mutating func next() -> UpdatableWrapper? {
            let currentNode = node
            node = currentNode?.next
            return currentNode?.object
        }
    }

    func makeIterator() -> Iterator {
        return Iterator(node: firstNode)
    }
}

private extension UpdatableCollection {
    final class Node {
        let object: UpdatableWrapper
        weak var previous: Node?
        var next: Node?

        init(object: UpdatableWrapper) {
            self.object = object
        }
    }
}
