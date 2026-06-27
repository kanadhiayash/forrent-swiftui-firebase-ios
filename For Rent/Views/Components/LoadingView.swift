//
//  LoadingView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct LoadingView: View {
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.08).ignoresSafeArea()
            
            HStack(spacing: ForRentTheme.Spacing.sm) {
                ProgressView()
                    .tint(ForRentTheme.Colors.action)

                Text("Loading")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ForRentTheme.Colors.ink)
            }
            .padding(.horizontal, ForRentTheme.Spacing.md)
            .padding(.vertical, ForRentTheme.Spacing.sm)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))
            .shadow(color: Color.black.opacity(0.1), radius: 12, y: 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading")
    }
}

struct ListingSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.media)
                .fill(ForRentTheme.Colors.surfaceStrong)
                .frame(height: 208)

            RoundedRectangle(cornerRadius: 4)
                .fill(ForRentTheme.Colors.surfaceStrong)
                .frame(height: 20)

            RoundedRectangle(cornerRadius: 4)
                .fill(ForRentTheme.Colors.surfaceSoft)
                .frame(width: 190, height: 16)
        }
        .padding(ForRentTheme.Spacing.md)
        .redacted(reason: .placeholder)
        .accessibilityLabel("Loading rental listing")
    }
}
