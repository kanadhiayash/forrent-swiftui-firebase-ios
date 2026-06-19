//
//  Extensions.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import Foundation

// MARK: - View Extensions

extension View {
    
    func cardStyle() -> some View {
        self
            .padding(ForRentTheme.Spacing.lg)
            .background(ForRentTheme.Colors.canvas)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.card, style: .continuous)
                    .stroke(ForRentTheme.Colors.hairline, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 16, x: 0, y: 8)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .buttonStyle(ForRentPrimaryButtonStyle())
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .buttonStyle(ForRentSecondaryButtonStyle())
    }
}

// MARK: - String Extensions

extension String {
    
    var isValidEmail: Bool {
        return contains("@") && contains(".")
    }
}

// MARK: - Double Extensions

extension Double {
    
    func toCurrency() -> String {
        return Self.currencyFormatter.string(from: NSNumber(value: self)) ?? String(format: "$%.0f CAD", self)
    }
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_CA")
        return formatter
    }()
}
