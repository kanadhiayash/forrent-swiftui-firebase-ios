//
//  StatusChip.swift
//  For Rent
//
//  Created by Codex on 2026-06-18.
//

import SwiftUI

enum StatusChipTone {
    case neutral
    case success
    case warning
    case danger
    case info
    
    var foregroundColor: Color {
        switch self {
        case .neutral:
            return ForRentTheme.Colors.ink
        case .success:
            return ForRentTheme.Colors.forest
        case .warning:
            return ForRentTheme.Colors.primary
        case .danger:
            return ForRentTheme.Colors.coral
        case .info:
            return ForRentTheme.Colors.linkActive
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .neutral:
            return ForRentTheme.Colors.surfaceSoft
        case .success:
            return ForRentTheme.Colors.mint.opacity(0.45)
        case .warning:
            return ForRentTheme.Colors.yellow.opacity(0.5)
        case .danger:
            return ForRentTheme.Colors.peach.opacity(0.32)
        case .info:
            return ForRentTheme.Colors.cream
        }
    }
    
    var borderColor: Color {
        switch self {
        case .neutral:
            return ForRentTheme.Colors.hairline
        case .success:
            return ForRentTheme.Colors.mint
        case .warning:
            return ForRentTheme.Colors.mustard
        case .danger:
            return ForRentTheme.Colors.peach
        case .info:
            return ForRentTheme.Colors.link.opacity(0.25)
        }
    }
}

struct StatusChip: View {
    
    let title: String
    let systemImage: String
    var tone: StatusChipTone = .neutral
    
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tone.foregroundColor)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous)
                    .fill(tone.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous)
                    .stroke(tone.borderColor, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
    }
}
