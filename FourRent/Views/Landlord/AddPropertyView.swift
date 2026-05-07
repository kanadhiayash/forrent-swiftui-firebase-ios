//
//  AddPropertyView.swift
//  FourRent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct AddPropertyView: View {
    
    @EnvironmentObject var propertyVM: PropertyViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var details = ""
    @State private var rent = ""
    
    @State private var bedrooms = 1
    @State private var bathrooms = 1
    
    @State private var locationQuery = ""
    @State private var latitude: Double = 43.6532
    @State private var longitude: Double = -79.3832
    
    @State private var images: [UIImage] = []
    
    @State private var isListed = true
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 20) {
                
                Text("Add Property")
                    .font(.title.bold())
                
                Group {
                    TextField("Title", text: $title)
                    TextField("Description", text: $details)
                    TextField("Rent (CAD)", text: $rent)
                        .keyboardType(.decimalPad)
                }
                .textFieldStyle(.roundedBorder)
                
                // STEPPERS
                Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 0...10)
                Stepper("Bathrooms: \(bathrooms)", value: $bathrooms, in: 0...10)
                
                // IMAGE PICKER
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(10)
                        }
                    }
                }
                
                ImagePicker(selectedImages: $images)
                
                // LOCATION SEARCH
                LocationSearchView(
                    query: $locationQuery,
                    latitude: $latitude,
                    longitude: $longitude
                )
                
                // MAP
                MapView(latitude: latitude, longitude: longitude)
                
                // LIST TOGGLE
                Toggle("List Property", isOn: $isListed)
                
                Button("Add Property") {
                    guard authVM.user?.role == .landlord,
                          let landlordId = authVM.user?.id else {
                        propertyVM.errorMessage = "Only landlords can add properties."
                        return
                    }
                    
                    guard let rentValue = Double(rent.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                        propertyVM.errorMessage = "Enter a valid rent amount."
                        return
                    }
                    
                    Task {
                        await propertyVM.addProperty(
                            title: title,
                            details: details,
                            rent: rentValue,
                            bedrooms: bedrooms,
                            bathrooms: bathrooms,
                            latitude: latitude,
                            longitude: longitude,
                            images: images,
                            landlordId: landlordId,
                            isListed: isListed
                        )
                        
                        if propertyVM.errorMessage == nil {
                            dismiss()
                        }
                    }
                }
                .disabled(propertyVM.isLoading)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .overlay {
            if propertyVM.isLoading {
                LoadingView()
            }
        }
        .showError($propertyVM.errorMessage)
    }
}
