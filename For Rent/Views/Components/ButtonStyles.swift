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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    let configuration: ButtonStyle.Configuration
    let kind: Kind
    
    var body: some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, ForRentTheme.Spacing.md)
            .frame(minHeight: ForRentTheme.Control.standardHeight)
            .background(backgroundShape)
            .contentShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous))
            .frame(minHeight: ForRentTheme.Control.minimumTarget)
            .opacity(isEnabled ? 1 : 0.55)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.98 : 1))
            .animation(
                reduceMotion ? nil : .easeOut(duration: ForRentTheme.Motion.fast),
                value: configuration.isPressed
            )
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
            return isEnabled ? ForRentTheme.Brand.white : ForRentTheme.Colors.textMuted
        case .secondary:
            return isEnabled ? ForRentTheme.Colors.textPrimary : ForRentTheme.Colors.textMuted
        }
    }
    
    private var backgroundColor: Color {
        switch kind {
        case .primary:
            guard isEnabled else { return ForRentTheme.Colors.surfaceSubtle }
            return configuration.isPressed ? ForRentTheme.Colors.actionPressed : ForRentTheme.Colors.actionPrimary
        case .secondary:
            return configuration.isPressed ? ForRentTheme.Colors.surfaceSubtle : ForRentTheme.Colors.surface
        }
    }
    
    private var borderColor: Color {
        switch kind {
        case .primary:
            return .clear
        case .secondary:
            return isEnabled ? ForRentTheme.Colors.border : ForRentTheme.Colors.separator
        }
    }
}
