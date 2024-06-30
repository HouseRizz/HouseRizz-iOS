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
        let placementSettings = PlacementSettingsViewModel()
        let sessionSettings = ARSessionSettingsViewModel()
        let sceneManager = SceneManager()
        let modelsViewModel = HR3DModelViewModel()
        let modelDeletionManager = ModelDeletionManager()
        let contentView = MainView()
            .environmentObject(cartViewModel)
            .environmentObject(searchViewModel)
            .environmentObject(placementSettings)
            .environmentObject(sessionSettings)
            .environmentObject(sceneManager)
            .environmentObject(modelsViewModel)
            .environmentObject(modelDeletionManager)

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

