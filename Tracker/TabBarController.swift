//
//  TabBarController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

final class TabBarController: UITabBarController {

    private let coreDataStack: CoreDataStack
    private let trackersProvider: TrackersProvider

    init(coreDataStack: CoreDataStack, trackersProvider: TrackersProvider) {
        self.coreDataStack = coreDataStack
        self.trackersProvider = trackersProvider
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let trackersVC = TrackersViewController(coreDataStack: coreDataStack, provider: trackersProvider)
        let trackersNC = UINavigationController(rootViewController: trackersVC)
        trackersNC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_trackers_selected")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab_trackers_selected")?.withRenderingMode(.alwaysOriginal)
        )

        let statsProvider = StatisticsProviderCoreData(stack: coreDataStack)
        let statsVC = StatisticsViewController(provider: statsProvider)
        let statsNC = UINavigationController(rootViewController: statsVC)
        statsNC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistics")?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: "tab_statistics")?.withRenderingMode(.alwaysOriginal)
        )

        viewControllers = [trackersNC, statsNC]

        tabBar.tintColor = .ypBlackDay
        if #available(iOS 15.0, *) {
            let ap = UITabBarAppearance()
            ap.configureWithOpaqueBackground()
            ap.backgroundColor = .ypWhiteDay
            tabBar.standardAppearance = ap
            tabBar.scrollEdgeAppearance = ap
        }
    }
}
