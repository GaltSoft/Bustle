
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        // Set Themes and Styling
        ThemeManager.setupStyling()
        let theme = ThemeManager.currentTheme()
        ThemeManager.applyTheme(theme: theme)
        return true
    }


    func applicationWillTerminate(_ application: UIApplication) {
    }

}
