//
//  PropertyCardView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct PropertyCardView: View {
    
    var property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.md) {
            propertyImage
            
            VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
                    Text(property.title)
                        .font(.headline)
                        .foregroundStyle(ForRentTheme.Colors.ink)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(property.rent.toCurrency()) / month")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(ForRentTheme.Colors.ink)
                    
                    if !property.details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(property.details)
                            .font(.subheadline)
                            .foregroundStyle(ForRentTheme.Colors.body)
                            .lineLimit(2)
                    }
                }
                
                HStack(spacing: ForRentTheme.Spacing.xs) {
                    PropertyFactBadge(
                        systemImage: "bed.double.fill",
                        text: property.bedrooms == 1 ? "1 bed" : "\(property.bedrooms) beds"
                    )
                    
                    PropertyFactBadge(
                        systemImage: "bathtub.fill",
                        text: property.bathrooms == 1 ? "1 bath" : "\(property.bathrooms) baths"
                    )
                }
                
                HStack(spacing: ForRentTheme.Spacing.xs) {
                    StatusChip(
                        title: listingStatus.title,
                        systemImage: listingStatus.systemImage,
                        tone: listingStatus.tone
                    )
                    
                    StatusChip(
                        title: occupancyStatus.title,
                        systemImage: occupancyStatus.systemImage,
                        tone: occupancyStatus.tone
                    )
                }
                .accessibilityElement(children: .contain)
            }
        }
        .cardStyle()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityHint("Shows the property image, monthly rent, facts, and listing status.")
    }
    
    private var propertyImage: some View {
        Group {
            if let first = property.imageNames.first,
               let image = ImageManager.shared.loadImage(name: first) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.media, style: .continuous)
                    .fill(ForRentTheme.Colors.surfaceSoft)
                    .overlay {
                        VStack(spacing: ForRentTheme.Spacing.xs) {
                            Image(systemName: "photo")
                                .font(.title3)
                                .foregroundStyle(ForRentTheme.Colors.muted)
                            
                            Text("Image unavailable")
                                .font(.subheadline)
                                .foregroundStyle(ForRentTheme.Colors.muted)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 208)
        .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.media, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ForRentTheme.Radius.media, style: .continuous)
                .stroke(ForRentTheme.Colors.hairline, lineWidth: 1)
        )
        .accessibilityHidden(true)
    }
    
    private var listingStatus: (title: String, systemImage: String, tone: StatusChipTone) {
        if property.isListed {
            return ("Listed", "eye.fill", .info)
        }
        
        return ("Not listed", "eye.slash.fill", .neutral)
    }
    
    private var occupancyStatus: (title: String, systemImage: String, tone: StatusChipTone) {
        if property.isAssigned {
            return ("Assigned", "person.fill.checkmark", .warning)
        }
        
        if property.isListed {
            return ("Available", "checkmark.circle.fill", .success)
        }
        
        return ("Unavailable", "minus.circle.fill", .danger)
    }
    
    private var accessibilitySummary: String {
        [
            property.title,
            "\(property.rent.toCurrency()) per month",
            property.bedrooms == 1 ? "1 bedroom" : "\(property.bedrooms) bedrooms",
            property.bathrooms == 1 ? "1 bathroom" : "\(property.bathrooms) bathrooms",
            listingStatus.title,
            occupancyStatus.title
        ].joined(separator: ", ")
    }
}

private struct PropertyFactBadge: View {
    
    let systemImage: String
    let text: String
    
    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(ForRentTheme.Colors.body)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous)
                    .fill(ForRentTheme.Colors.surfaceSoft)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ForRentTheme.Radius.control, style: .continuous)
                    .stroke(ForRentTheme.Colors.hairline, lineWidth: 1)
            )
    }
}
