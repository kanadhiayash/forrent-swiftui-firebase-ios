//
//  PropertyCardView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct PropertyCardView: View {
    
    var property: Property
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 10) {
            
            // IMAGE
            if let first = property.imageNames.first,
               let image = ImageManager.shared.loadImage(name: first) {
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipped()
                    .cornerRadius(14)
                    
            } else {
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 220)
                    .overlay(Text("No Image"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                
                Text(property.title)
                    .font(.headline)
                
                Text("$\(property.rent, specifier: "%.0f") / month")
                    .font(.subheadline)
                    .bold()
                
                Text("\(property.bedrooms) beds • \(property.bathrooms) baths")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Lat: \(property.latitude, specifier: "%.2f"), Lon: \(property.longitude, specifier: "%.2f")")
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                HStack {
                    Label(property.isListed ? "Listed" : "De-listed", systemImage: property.isListed ? "eye" : "eye.slash")
                    Label(property.isAssigned ? "Assigned" : "Available", systemImage: property.isAssigned ? "checkmark.circle.fill" : "circle")
                }
                .font(.caption2)
                .foregroundColor(property.isListed && !property.isAssigned ? .green : .secondary)
            }
        }
        .padding(.bottom, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(property.title), \(property.rent.toCurrency()) per month, \(property.bedrooms) bedrooms, \(property.bathrooms) bathrooms")
    }
}
