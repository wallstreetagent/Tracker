//
//  Colors.swift
//  Tracker
//
//  Created by Yanye Velikanova on 10/8/25.
//

import UIKit

final class Colors {
    static let shared = Colors()
    private init() {}

   
    let background = UIColor(named: "AppBackground") ?? .systemBackground


    let secondary = UIColor(named: "AppSecondary") ?? .secondarySystemBackground


    let accent = UIColor(named: "Accent") ?? .systemBlue


    let label = UIColor.label
    let labelSecondary = UIColor.secondaryLabel

  
    let buttonDisabledColor = UIColor { traits in
        traits.userInterfaceStyle == .light
        ? .lightGray
        : UIColor(red: 0.8, green: 0.5, blue: 0.8, alpha: 1)
    }
}
