//
//  TabBarController.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/18/25.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .systemBackground

        appearance.shadowColor = UIColor.separator

                tabBar.standardAppearance = appearance
                tabBar.scrollEdgeAppearance = appearance
        
        let trackersNC = UINavigationController(rootViewController: TrackersViewController())
        trackersNC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_trackers_selected"),
            tag: 0
        )


        let statsNC = UINavigationController(rootViewController: StatisticsViewController())
        statsNC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistics"),
            tag: 1
        )

        viewControllers = [trackersNC, statsNC]
    }
}
