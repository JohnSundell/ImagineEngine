import Foundation
@testable import ImagineEngine

final class GameViewMock: GameView {
    var mockedSafeAreaInsets = EdgeInsets()

    #if !os(macOS)
    override var safeAreaInsets: EdgeInsets {
        return mockedSafeAreaInsets
    }
    #endif
}
