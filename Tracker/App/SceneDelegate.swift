//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // MARK: - Scene Lifecycle
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let stack = CoreDataStack(modelName: "TrackerModel")
        let provider = TrackersProviderCoreData(stack: stack)
        let window = UIWindow(windowScene: windowScene)

        if OnboardingFlag.isSeen {
            window.rootViewController = TabBarController(coreDataStack: stack,
                                                         trackersProvider: provider)
        } else {
            let onboarding = OnboardingViewController()
            onboarding.onFinish = { [weak self] in
                OnboardingFlag.isSeen = true
                let tabBar = TabBarController(coreDataStack: stack,
                                              trackersProvider: provider)
                self?.window?.rootViewController = tabBar
                self?.window?.makeKeyAndVisible()
            }
            window.rootViewController = onboarding
        }

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?
            .coreDataStack.saveViewContextIfNeeded()
    }
}
    
    

