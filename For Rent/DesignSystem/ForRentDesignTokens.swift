//
//  ForRentDesignTokens.swift
//  For Rent
//
//  Created by Codex on 2026-06-18.
//

import SwiftUI

enum ForRentTheme {
    
    enum Colors {
        static let primary = Color(hex: 0x181D26)
        static let primaryActive = Color(hex: 0x0D1218)
        static let ink = Color(hex: 0x181D26)
        static let body = Color(hex: 0x333840)
        static let muted = Color(hex: 0x41454D)
        static let canvas = Color(hex: 0xFFFFFF)
        static let surfaceSoft = Color(hex: 0xF8FAFC)
        static let surfaceStrong = Color(hex: 0xE0E2E6)
        static let hairline = Color(hex: 0xDDDDDD)
        static let borderStrong = Color(hex: 0x9297A0)
        
        static let coral = Color(hex: 0xAA2D00)
        static let forest = Color(hex: 0x0A2E0E)
        static let cream = Color(hex: 0xF5E9D4)
        static let peach = Color(hex: 0xFCAB79)
        static let mint = Color(hex: 0xA8D8C4)
        static let yellow = Color(hex: 0xF4D35E)
        static let mustard = Color(hex: 0xD9A441)
        
        static let link = Color(hex: 0x1B61C9)
        static let linkActive = Color(hex: 0x1A3866)
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
}

private extension Color {
    
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
