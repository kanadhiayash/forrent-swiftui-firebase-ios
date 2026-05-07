//
//  LoadingView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            
            ProgressView("Loading...")
                .padding()
                .background(.white)
                .cornerRadius(12)
        }
    }
}
