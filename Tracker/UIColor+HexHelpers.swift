//
//  UIColor+HexHelpers.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/25/25.
//

import UIKit

public extension UIColor {

    // ===== Хелпер HEX -> UIColor (без init, чтобы исключить конфликты) =====
    /// Поддерживает "#RRGGBB", "RRGGBB", "#RRGGBBAA", "RGB"
    static func fromHex(_ hex: String, fallback: UIColor = .systemGreen) -> UIColor {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        if s.hasPrefix("0X") { s.removeFirst(2) }

        var value: UInt64 = 0
        guard Scanner(string: s).scanHexInt64(&value) else { return fallback }

        switch s.count {
        case 3: // RGB (12-bit)
            let r = CGFloat((value >> 8) & 0xF) / 15.0
            let g = CGFloat((value >> 4) & 0xF) / 15.0
            let b = CGFloat( value        & 0xF) / 15.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)

        case 6: // RRGGBB
            let r = CGFloat((value >> 16) & 0xFF) / 255.0
            let g = CGFloat((value >>  8) & 0xFF) / 255.0
            let b = CGFloat( value         & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)

        case 8: // RRGGBBAA
            let r = CGFloat((value >> 24) & 0xFF) / 255.0
            let g = CGFloat((value >> 16) & 0xFF) / 255.0
            let b = CGFloat((value >>  8) & 0xFF) / 255.0
            let a = CGFloat( value         & 0xFF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: a)

        default:
            return fallback
        }
    }

    // ===== Цвета под макет (без ассетов) =====
    static var ypWhiteDay: UIColor { .white }
    static var ypBlackDay: UIColor { UIColor.fromHex("#1A1B22", fallback: .black) }
    static var ypBlue: UIColor { .systemBlue }
    static var ypBackground: UIColor { .systemGray6 }
}
