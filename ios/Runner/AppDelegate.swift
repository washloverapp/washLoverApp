import UIKit
import Flutter
import GoogleMaps

// import GoogleNavigation

import Firebase // ✅ เพิ่ม Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // GMSServices.provideAPIKey("AIzaSyDEds_3tBG5jdPMRLZyBl1EJFo196mjNgs")
        GMSServices.provideAPIKey("AIzaSyDY3WOnRKFdGTKnzM9fx6xdCh2gktnz0XE")
        FirebaseApp.configure() // ✅ สำคัญมาก ต้องมีบรรทัดนี้

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
