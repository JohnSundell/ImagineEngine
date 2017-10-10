import Foundation

internal protocol DisplayLinkProtocol: class {
    var callback: () -> Void { get set }
    func activate()
}
