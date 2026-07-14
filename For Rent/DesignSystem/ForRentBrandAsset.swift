//
//  ForRentBrandAsset.swift
//  For Rent
//
import SwiftUI

struct ForRentBrandAsset: View {
    enum Kind {
        case symbol
        case horizontalLogo
    }

    let kind: Kind
    var accessibilityLabel: String? = nil

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .accessibilityLabel(accessibilityLabel ?? defaultAccessibilityLabel)
    }

    private var assetName: String {
        switch kind {
        case .symbol:
            ForRentTheme.Assets.symbol
        case .horizontalLogo:
            ForRentTheme.Assets.horizontalLogo
        }
    }

    private var defaultAccessibilityLabel: String {
        switch kind {
        case .symbol:
            "For Rent"
        case .horizontalLogo:
            "For Rent"
        }
    }
}
