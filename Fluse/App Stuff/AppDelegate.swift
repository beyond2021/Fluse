//
//  AppDelegate.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 5/9/24.
//
import Firebase
import FirebaseFirestore
import Foundation

#if os(macOS)
import Cocoa
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
       setupFirebase()
    }
}
#else
import UIKit
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupFirebase()
        return true
    }
    
}

#endif

fileprivate func isPreViewRuntime() -> Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
fileprivate func setupFirebase() {
    FirebaseApp.configure()
    if isPreViewRuntime() {
        // get fb settings
        let settings = Firestore.firestore().settings
        settings.host = "localhost:8080"
        settings.isPersistenceEnabled = false //TODO
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
    }
}
