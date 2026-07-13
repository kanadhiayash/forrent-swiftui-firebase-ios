//
//  ForRentDesignTokens.swift
//  For Rent
//
//  Created by Codex on 2026-06-18.
//

import SwiftUI

enum ForRentTheme {
    enum Brand {
        static let navy = Color("BrandNavy")
        static let royalBlue = Color("BrandRoyalBlue")
        static let teal = Color("BrandTeal")
        static let lightGray = Color("BrandLightGray")
        static let white = Color("BrandWhite")
    }

    enum Assets {
        static let symbol = "BrandSymbol"
        static let horizontalLogo = "BrandLogoHorizontal"
    }

    enum Colors {
        static let canvas = Color("AppCanvas")
        static let surface = Color("AppSurface")
        static let surfaceSubtle = Color("AppSurfaceSubtle")
        static let surfaceRaised = Color("AppSurfaceRaised")
        static let surfaceSelected = Color("AppSurfaceSelected")

        static let textPrimary = Color("AppTextPrimary")
        static let textSecondary = Color("AppTextSecondary")
        static let textMuted = Color("AppTextMuted")

        static let border = Color("AppBorder")
        static let separator = Color("AppSeparator")

        static let actionPrimary = Color("AppActionPrimary")
        static let actionPressed = Color("AppActionPressed")
        static let link = Color("AppLink")
        static let focus = Color("AppFocus")

        static let success = Color("AppSuccess")
        static let successSurface = Color("AppSuccessSurface")
        static let warning = Color("AppWarning")
        static let warningSurface = Color("AppWarningSurface")
        static let destructive = Color("AppDestructive")
        static let destructiveSurface = Color("AppDestructiveSurface")

        // Compatibility aliases for existing screens. New code should use semantic names.
        static let primary = Brand.navy
        static let primaryActive = Brand.navy
        static let action = actionPrimary
        static let actionActive = actionPressed
        static let ink = textPrimary
        static let body = textSecondary
        static let muted = textMuted
        static let surfaceSoft = surfaceSubtle
        static let surfaceStrong = surfaceSelected
        static let hairline = separator
        static let borderStrong = border
        static let coral = destructive
        static let forest = success
        static let cream = surfaceSelected
        static let peach = destructiveSurface
        static let mint = successSurface
        static let yellow = warning
        static let mustard = warning
        static let linkActive = actionPressed
    }

    enum Typography {
        static let screenTitle = Font.largeTitle.weight(.bold)
        static let sectionTitle = Font.headline
        static let rowTitle = Font.body.weight(.semibold)
        static let body = Font.body
        static let supporting = Font.subheadline
        static let caption = Font.caption
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let screenHorizontal: CGFloat = 16
    }

    enum Radius {
        static let control: CGFloat = 12
        static let card: CGFloat = 16
        static let media: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Control {
        static let minimumTarget: CGFloat = 44
        static let standardHeight: CGFloat = 52
    }

    enum Motion {
        static let fast = 0.10
        static let standard = 0.20
        static let slow = 0.25
    }
}
