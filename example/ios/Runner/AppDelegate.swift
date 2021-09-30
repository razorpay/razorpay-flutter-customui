import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CRED_CALLBACK_NOTIFICATION"), object: nil, userInfo: ["response":url.absoluteString])
        }
        return true
    }
}
