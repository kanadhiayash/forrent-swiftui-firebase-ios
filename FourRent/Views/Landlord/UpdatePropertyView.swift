//
//  UpdatePropertyView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct UpdatePropertyView: View {
    
    @EnvironmentObject var propertyVM: PropertyViewModel
    
    var property: Property
    
    @State private var title = ""
    @State private var details = ""
    @State private var rent = ""
    
    @State private var bedrooms = 1
    @State private var bathrooms = 1
    
    @State private var latitude: Double = 43.6532
    @State private var longitude: Double = -79.3832
    
    @State private var images: [UIImage] = []
    
    @State private var isListed = true
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                Text("Update Property")
                    .font(.title.bold())
                
                Group {
                    TextField("Title", text: $title)
                    TextField("Description", text: $details)
                    TextField("Rent (CAD)", text: $rent)
                }
                .textFieldStyle(.roundedBorder)
                
                Stepper("Bedrooms: \(bedrooms)", value: $bedrooms)
                Stepper("Bathrooms: \(bathrooms)", value: $bathrooms)
                
                // EXISTING IMAGES
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                        }
                    }
                }
                
                // ADD NEW IMAGES
                ImagePicker(selectedImages: $images)
                
                // LIST / DELIST
                Toggle("Listed", isOn: $isListed)
                
                Button("Update Property") {
                    guard let rentValue = Double(rent.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                        propertyVM.errorMessage = "Enter a valid rent amount."
                        return
                    }
                    
                    Task {
                        var updated = property
                        updated.isListed = isListed
                        
                        await propertyVM.updateProperty(
                            property: updated,
                            title: title,
                            details: details,
                            rent: rentValue,
                            bedrooms: bedrooms,
                            bathrooms: bathrooms,
                            latitude: latitude,
                            longitude: longitude,
                            images: images
                        )
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(propertyVM.isLoading)
            }
            .padding()
        }
        .onAppear {
            title = property.title
            details = property.details
            rent = String(property.rent)
            bedrooms = property.bedrooms
            bathrooms = property.bathrooms
            latitude = property.latitude
            longitude = property.longitude
            isListed = property.isListed
            images = property.imageNames.compactMap {
                ImageManager.shared.loadImage(name: $0)
            }
        }
        .overlay {
            if propertyVM.isLoading {
                LoadingView()
            }
        }
        .showError($propertyVM.errorMessage)
    }
}
