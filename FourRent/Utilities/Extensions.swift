//
//  Extensions.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI
import Foundation

// MARK: - View Extensions

extension View {
    
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
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
        return String(format: "$%.0f CAD", self)
    }
}
