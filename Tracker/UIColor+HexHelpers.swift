//
//  UIColor+HexHelpers.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/25/25.
//

import UIKit

public extension UIColor {
    /// Инициализатор из HEX-строки. Поддерживает "#RRGGBB" и "RRGGBB".
    convenience init?(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let value = UInt32(s, radix: 16) else { return nil }
        let r = CGFloat((value & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((value & 0x00FF00) >>  8) / 255.0
        let b = CGFloat( value & 0x0000FF)        / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    // ===== Палитра под макет =====
    static var ypWhiteDay: UIColor { .white }
    static var ypBlackDay: UIColor { UIColor(hex: "#1A1B22") ?? .black }
    static var ypBlue: UIColor { .systemBlue }
    static var ypBackground: UIColor { .systemGray6 }
}
