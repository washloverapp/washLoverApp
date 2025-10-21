import UIKit
import Flutter
import GoogleMaps
import Firebase  // นำเข้า Firebase SDK
import UserNotifications  // นำเข้า UserNotifications สำหรับ iOS notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ตั้งค่า Google Maps API
    GMSServices.provideAPIKey("AIzaSyDEds_3tBG5jdPMRLZyBl1EJFo196mjNgs")  // ใส่ API Key ของ Google Maps ที่นี่
    
    // ตั้งค่า Firebase
    // FirebaseApp.configure()
    
    // ขออนุญาตการแจ้งเตือน
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if granted {
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()  // ลงทะเบียนสำหรับการแจ้งเตือน
        }
      }
    }
    
    // ลงทะเบียน plugins ที่ Flutter ใช้
    GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
