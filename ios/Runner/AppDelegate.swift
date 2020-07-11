import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Setting the interval of the background task, in seconds. So 60*60*12 is 12 hours.
    UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*60*12))
    
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    // The following added function shows banner even if app is in foreground
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notifcation: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
            
    }
}
