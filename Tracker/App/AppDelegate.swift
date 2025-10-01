//
//  AppDelegate.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit
#if canImport(AppMetricaCore)
import AppMetricaCore
#endif
#if canImport(YandexMobileMetrica)
import YandexMobileMetrica
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let coreDataStack = CoreDataStack(modelName: "TrackerModel")

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        #if canImport(AppMetricaCore)
        if let config = AppMetricaConfiguration(apiKey: "ddfdc0c0-15a0-41b6-952f-f89ee535729e") {
            AppMetrica.activate(with: config)
        }
        #elseif canImport(YandexMobileMetrica)
        if let config = YMMYandexMetricaConfiguration(apiKey: "ddfdc0c0-15a0-41b6-952f-f89ee535729e") {
            YMMYandexMetrica.activate(with: config)
        }
        #endif

        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
