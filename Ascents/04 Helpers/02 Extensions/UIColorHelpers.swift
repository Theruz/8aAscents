//
//  UIColorHelpers.swift
//  Ascents
//
//  Created by Theophile on 04.04.17.
//  Copyright © 2017 Theophile. All rights reserved.
//

import Foundation
import UIKit

// localization check:disable

extension UIColor {
    
    // MARK: Greys
    static var grey1: UIColor { return #colorLiteral(red: 0.2666666667, green: 0.2666666667, blue: 0.2666666667, alpha: 1) } // UIColor(hex:0x444444) //maintextcolor
    static var grey2: UIColor { return #colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1) } // UIColor(hex:0x929292) // light/second TextColor
    static var grey3: UIColor { return #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1) } // UIColor(hex:0xE0E0E0)
    static var grey4: UIColor { return #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1) } // UIColor(hex:0xF2F2F2)
    static var grey5: UIColor { return #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1) } // UIColor(hex:0xF6F6F6)
    
    // MARK: Blue
    static var blue1: UIColor { return #colorLiteral(red: 0, green: 0.2980392157, blue: 0.5490196078, alpha: 1) } // UIColor(hex:0x004C8C)
    static var blue2: UIColor { return #colorLiteral(red: 0.7529411765, green: 0.8392156863, blue: 0.9215686275, alpha: 1) } // UIColor(hex:0xC0D6EB)
    
    // MARK: red
    static var red1: UIColor { return #colorLiteral(red: 1, green: 0.2274509804, blue: 0.1882352941, alpha: 1) } // UIColor(hex:0x004C8C)
    
    // MARK: Convenience hexa initializer
    convenience init(hex: UInt, alphaVal: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaVal)
        )
    }
    
    func hexValue() -> String {
        
        let components = self.cgColor.components
        
        let r = Float((components?[0])!)
        let g = Float((components?[1])!)
        let b = Float((components?[2])!)
        
        return String(format: "#%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
    }
}
