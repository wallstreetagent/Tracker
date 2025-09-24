//
//  AppDelegate.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // ⭐ ОДИН-ЕДИНСТВЕННЫЙ экземпляр на всё приложение
    let coreDataStack = CoreDataStack(modelName: "TrackerModel") // замени имя, если .xcdatamodeld другое

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
