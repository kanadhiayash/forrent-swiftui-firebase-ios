//
//  BrandLockupView.swift
//  For Rent
//
//  Created by Codex on 2026-07-12.
//

import SwiftUI

struct BrandLockupView: View {
    var maxWidth: CGFloat = 260

    var body: some View {
        ForRentBrandAsset(kind: .horizontalLogo)
            .frame(maxWidth: maxWidth)
            .aspectRatio(115.0 / 38.0, contentMode: .fit)
    }
}
