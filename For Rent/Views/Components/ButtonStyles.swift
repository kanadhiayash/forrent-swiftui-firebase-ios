//
//  ButtonStyles.swift
//  For Rent
//
//  Created by Codex on 2026-06-18.
//

import SwiftUI

struct ForRentPrimaryButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, kind: .primary)
    }
}

struct ForRentSecondaryButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        StyledButton(configuration: configuration, kind: .secondary)
    }
}

private struct StyledButton: View {
    
    enum Kind {
        case primary
        case secondary
    }
    
    @Environment(\.isEnabled) private var isEnabled
    
    let configuration: ButtonStyle.Configuration
    let kind: Kind
    
    var body: some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, ForRentTheme.Spacing.md)
            .frame(minHeight: 52)
            .background(backgroundShape)
            .contentShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous))
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.18), value: configuration.isPressed)
    }
    
    @ViewBuilder
    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous)
                    .stroke(borderColor, lineWidth: kind == .secondary ? 1 : 0)
            )
    }
    
    private var foregroundColor: Color {
        switch kind {
        case .primary:
            return .white
        case .secondary:
            return isEnabled ? ForRentTheme.Colors.ink : ForRentTheme.Colors.muted
        }
    }
    
    private var backgroundColor: Color {
        switch kind {
        case .primary:
            guard isEnabled else { return ForRentTheme.Colors.surfaceStrong }
            return configuration.isPressed ? ForRentTheme.Colors.primaryActive : ForRentTheme.Colors.primary
        case .secondary:
            return configuration.isPressed ? ForRentTheme.Colors.surfaceStrong : ForRentTheme.Colors.canvas
        }
    }
    
    private var borderColor: Color {
        switch kind {
        case .primary:
            return .clear
        case .secondary:
            return isEnabled ? ForRentTheme.Colors.borderStrong : ForRentTheme.Colors.hairline
        }
    }
}
