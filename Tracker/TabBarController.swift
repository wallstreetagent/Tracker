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


        let trackersNC = UINavigationController(rootViewController: TrackersViewController())
        trackersNC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tab_trackers_selected"), // твоя иконка
            tag: 0
        )


        let statsNC = UINavigationController(rootViewController: StatisticsViewController())
        statsNC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tab_statistics"), // твоя иконка
            tag: 1
        )

        viewControllers = [trackersNC, statsNC]
    }
}

