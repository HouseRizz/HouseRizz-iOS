//
//  AppDelegate.swift
//  HouseRizz-iOS
//
//  Created by Krish Mittal on 04/04/24.
//

import UIKit
import SwiftUI
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        FirebaseApp.configure()

        let cartViewModel = CartViewModel()
        let searchViewModel = SearchViewModel()
        let contentView = SplashScreenView()
            .environmentObject(cartViewModel)
            .environmentObject(searchViewModel)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIHostingController(rootView: contentView)
        self.window = window
        window.makeKeyAndVisible()

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


}

