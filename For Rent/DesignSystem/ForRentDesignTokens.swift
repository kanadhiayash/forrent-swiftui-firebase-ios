//
//  ForRentDesignTokens.swift
//  For Rent
//
//  Created by Codex on 2026-06-18.
//

import SwiftUI
import UIKit

enum ForRentTheme {
    
    enum Colors {
        static let primary = Color(hex: 0x003580)
        static let primaryActive = Color(hex: 0x00224F)
        static let action = Color(light: 0x0071C2, dark: 0x4AA8E8)
        static let actionActive = Color(light: 0x005999, dark: 0x78C4F3)
        static let ink = Color(light: 0x1A1A1A, dark: 0xF5F5F5)
        static let body = Color(light: 0x595959, dark: 0xD1D1D1)
        static let muted = Color(light: 0x6B6B6B, dark: 0xA8A8A8)
        static let canvas = Color(light: 0xFFFFFF, dark: 0x0B0B0B)
        static let surfaceSoft = Color(light: 0xF5F5F5, dark: 0x1C1C1E)
        static let surfaceStrong = Color(light: 0xEBF3FF, dark: 0x11263F)
        static let hairline = Color(light: 0xE0E0E0, dark: 0x343438)
        static let borderStrong = Color(light: 0x595959, dark: 0xA8A8A8)
        
        static let coral = Color(light: 0xCC0000, dark: 0xFF6961)
        static let forest = Color(light: 0x008009, dark: 0x32D74B)
        static let cream = surfaceStrong
        static let peach = Color(light: 0xFFE7E7, dark: 0x3D1717)
        static let mint = Color(light: 0xE7F4E8, dark: 0x17341B)
        static let yellow = Color(hex: 0xFFB700)
        static let mustard = Color(light: 0xA66F00, dark: 0xFFCB45)
        
        static let link = action
        static let linkActive = actionActive
    }
    
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    enum Radius {
        static let control: CGFloat = 8
        static let card: CGFloat = 8
        static let media: CGFloat = 12
    }

    enum Motion {
        static let fast = 0.10
        static let standard = 0.20
        static let slow = 0.25
    }
}

private extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(
            uiColor: UIColor { traits in
                UIColor(
                    hex: traits.userInterfaceStyle == .dark ? dark : light
                )
            }
        )
    }
    
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
