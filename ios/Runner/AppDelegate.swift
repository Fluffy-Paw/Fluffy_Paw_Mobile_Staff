import Flutter
import UIKit
import flutter_local_notifications
import UserNotifications
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
 override func application(
   _ application: UIApplication,
   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
 ) -> Bool {
   // Firebase configuration
   FirebaseApp.configure()
   
   // Notifications setup
   if #available(iOS 10.0, *) {
     UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
     
     let center = UNUserNotificationCenter.current()
     center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
       if granted {
         DispatchQueue.main.async {
           application.registerForRemoteNotifications()
         }
       }
     }
   }
   
   // Flutter Local Notifications setup
   FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
     GeneratedPluginRegistrant.register(with: registry)
   }
   
   GeneratedPluginRegistrant.register(with: self)
   return super.application(application, didFinishLaunchingWithOptions: launchOptions)
 }

 // Existing notification handlers remain unchanged
 override func userNotificationCenter(
   _ center: UNUserNotificationCenter,
   willPresent notification: UNNotification,
   withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
 ) {
   completionHandler([[.alert, .sound]])
 }
 
 override func userNotificationCenter(
   _ center: UNUserNotificationCenter,
   didReceive response: UNNotificationResponse,
   withCompletionHandler completionHandler: @escaping () -> Void
 ) {
   completionHandler()
 }
}