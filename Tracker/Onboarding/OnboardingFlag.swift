//
//  OnboardingFlag.swift
//  Tracker
//
//  Created by Yanye Velikanova on 9/19/25.
//

import Foundation

enum OnboardingFlag {
    private static let key = "hasSeenOnboarding"

    static var isSeen: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}
