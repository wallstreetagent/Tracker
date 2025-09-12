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

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = UIColor.separator
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        let trackersVC = TrackersViewController(coreDataStack: coreDataStack, provider: trackersProvider)
        let trackersNC = UINavigationController(rootViewController: trackersVC)
        trackersNC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(named: "tab_trackers_selected"), tag: 0)

        let statsNC = UINavigationController(rootViewController: StatisticsViewController())
        statsNC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(named: "tab_statistics"), tag: 1)

        viewControllers = [trackersNC, statsNC]
    }
}
