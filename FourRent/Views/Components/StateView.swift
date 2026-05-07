//
//  StateView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct StateView<Content: View>: View {
    
    var isLoading: Bool
    var errorMessage: String?
    var retryAction: (() -> Void)? = nil
    
    let content: () -> Content
    
    var body: some View {
        
        if isLoading {
            
            VStack(spacing: 12) {
                ProgressView()
                Text("Loading...")
                    .foregroundColor(.gray)
            }
            
        } else if let error = errorMessage {
            
            ErrorView(
                message: error,
                retryAction: retryAction
            )
            
        } else {
            
            content()
        }
    }
}
