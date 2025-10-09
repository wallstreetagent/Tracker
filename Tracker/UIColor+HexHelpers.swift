//
//  UIColor+HexHelpers.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/25/25.
//

import UIKit

public extension UIColor {

    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0x00FF00) >>  8) / 255.0
        let b = CGFloat( value & 0x0000FF)        / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }


    static var ypWhiteDay: UIColor { UIColor(named: "AppBackground") ?? .systemBackground }

    static var ypBlackDay: UIColor { UIColor(named: "LabelPrimary") ?? .label }

    static var ypBlue: UIColor { UIColor(named: "Accent") ?? .systemBlue }

    static var ypBackground: UIColor { UIColor(named: "CardBackground") ?? .secondarySystemBackground }

    static var appSeparator: UIColor { UIColor(named: "Separator") ?? .separator }
  //   static var labelSecondary: UIColor { UIColor(named: "LabelSecondary") ?? .secondaryLabel }
    // static var buttonPrimary: UIColor { UIColor(named: "ButtonPrimary") ?? .black }
    static var brandBlue: UIColor { UIColor(named: "Accent") ?? UIColor(hex: "#3772E7") ?? .systemBlue }
}
