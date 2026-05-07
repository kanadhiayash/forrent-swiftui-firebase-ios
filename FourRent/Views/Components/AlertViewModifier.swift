//
//  AlertViewModifier.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct AlertViewModifier: ViewModifier {
    
    @Binding var message: String?
    
    func body(content: Content) -> some View {
        content.alert("Error", isPresented: Binding(
            get: { message != nil },
            set: { _ in message = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(message ?? "")
        }
    }
}

extension View {
    func showError(_ message: Binding<String?>) -> some View {
        self.modifier(AlertViewModifier(message: message))
    }
}
