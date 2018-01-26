import UIKit
import ImagineEngine

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let scene = ___PACKAGENAME___Scene(size: UIScreen.main.bounds.size)

        let window = GameWindow(scene: scene)
        window.makeKeyAndVisible()
        self.window = window

        return true
    }
}
