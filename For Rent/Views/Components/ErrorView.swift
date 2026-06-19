//
//  ErrorView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct ErrorView: View {
    
    var message: String
    var retryAction: (() -> Void)? = nil
    var dismissAction: (() -> Void)? = nil
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            Spacer()
            
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Something went wrong")
                .font(.title2.bold())
            
            Text(message)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // ✅ Retry Button
            if let retryAction {
                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
            }
            
            // ✅ Dismiss Button
            if let dismissAction {
                Button("Dismiss") {
                    dismissAction()
                }
                .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
    }
}
