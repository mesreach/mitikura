import UIKit
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private let cGoogleMapsAPIKey = "AIzaSyB2VMdWQslynrxRgCA3vpWQAjqxvkKmCWk"
    private let cGooglePlacesAPIKey = "AIzaSyC2i7Tin4zjz0s9uXCg7jcOUhX-VQHG56g"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(cGoogleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(cGooglePlacesAPIKey)
        sleep(2)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

