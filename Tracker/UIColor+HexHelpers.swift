//
//  UIColor+HexHelpers.swift
//  Tracker
//
//  Created by Yanye Velikanova on 8/25/25.
//

import UIKit

public extension UIColor {

    static func hex(_ hexString: String, fallback: UIColor = .systemGreen) -> UIColor {
        return UIColor(hex: hexString) ?? fallback
    }


    static func fromHex(_ hexString: String) -> UIColor {
        return UIColor(hex: hexString) ?? .systemGreen
    }
}
