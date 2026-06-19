//
//  UpdatePropertyView.swift
//  For Rent
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

    @State private var category: RentalCategory = .personalLiving
    @State private var pricingCadence: PricingCadence = .monthly
    @State private var amenitiesText = ""
    @State private var maxGuests = 2

    @State private var bedrooms = 1
    @State private var bathrooms = 1

    @State private var locationName = ""
    @State private var locationQuery = ""
    @State private var latitude: Double = 43.6532
    @State private var longitude: Double = -79.3832

    @State private var images: [UIImage] = []

    @State private var isListed = true
    @State private var hasLoadedState = false

    var body: some View {

        Form {
            basicsSection
            categorySection
            pricingSection
            layoutSection
            amenitiesSection
            locationSection
            mediaSection
            publishingSection
            submitSection
        }
        .navigationTitle("Update Property")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            populateFormIfNeeded()
        }
        .onChange(of: category) { _, newValue in
            syncCategoryState(for: newValue)
        }
        .onChange(of: locationQuery) { previousValue, newValue in
            let trimmedLocationName = locationName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedLocationName.isEmpty || trimmedLocationName == previousValue {
                locationName = newValue
            }
        }
        .overlay {
            if propertyVM.isLoading {
                LoadingView()
            }
        }
        .showError($propertyVM.errorMessage)
    }

    private var basicsSection: some View {
        Section {
            TextField("Listing title", text: $title)

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline.weight(.semibold))

                TextEditor(text: $details)
                    .frame(minHeight: 120)
            }
        } header: {
            Text("Basics")
        }
    }

    private var categorySection: some View {
        Section {
            Picker("Rental category", selection: $category) {
                ForEach(RentalCategory.allCases) { category in
                    Text(category.title).tag(category)
                }
            }

            Text(category.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
        } header: {
            Text("Rental Type")
        }
    }

    private var pricingSection: some View {
        Section {
            TextField("\(category.pricingFieldLabel) (CAD)", text: $rent)
                .keyboardType(.decimalPad)

            Picker("Pricing cadence", selection: $pricingCadence) {
                ForEach(category.allowedPricingCadences) { cadence in
                    Text(cadence.title).tag(cadence)
                }
            }
        } header: {
            Text("Pricing")
        }
    }

    private var layoutSection: some View {
        Section {
            Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 0...10)
            Stepper("Bathrooms: \(bathrooms)", value: $bathrooms, in: 0...10)

            if category.supportsGuestCount {
                Stepper("Max guests: \(maxGuests)", value: $maxGuests, in: 1...20)
            }
        } header: {
            Text("Capacity")
        }
    }

    private var amenitiesSection: some View {
        Section {
            TextField("Wi-Fi, parking, laundry, workspace", text: $amenitiesText)
        } header: {
            Text("Amenities")
        } footer: {
            Text("Separate amenities with commas.")
        }
    }

    private var locationSection: some View {
        Section {
            TextField("Display location", text: $locationName)

            LocationSearchView(
                query: $locationQuery,
                latitude: $latitude,
                longitude: $longitude
            )

            MapView(latitude: latitude, longitude: longitude)
                .frame(minHeight: 220)
        } header: {
            Text("Location")
        } footer: {
            Text("Display location is the renter-facing label. The map pin stays available for discovery and proximity checks.")
        }
    }

    private var mediaSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 88, height: 88)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                .padding(.vertical, 4)
            }

            ImagePicker(selectedImages: $images)
        } header: {
            Text("Media")
        }
    }

    private var publishingSection: some View {
        Section {
            Toggle("Listed", isOn: $isListed)
        } header: {
            Text("Publishing")
        }
    }

    private var submitSection: some View {
        Section {
            Button("Update Property") {
                saveProperty()
            }
            .buttonStyle(.borderedProminent)
            .disabled(propertyVM.isLoading)
        }
    }

    private func populateFormIfNeeded() {
        guard !hasLoadedState else { return }

        title = property.title
        details = property.details
        rent = String(property.rent)
        category = property.category
        pricingCadence = property.resolvedPricingCadence
        amenitiesText = property.resolvedAmenities.joined(separator: ", ")
        maxGuests = property.resolvedMaxGuests ?? 2
        bedrooms = property.bedrooms
        bathrooms = property.bathrooms
        locationName = property.locationName ?? property.resolvedLocationName
        locationQuery = locationName
        latitude = property.latitude
        longitude = property.longitude
        isListed = property.isListed
        images = property.imageNames.compactMap {
            ImageManager.shared.loadImage(name: $0)
        }

        hasLoadedState = true
    }

    private func saveProperty() {
        guard let rentValue = Double(rent.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            propertyVM.errorMessage = "Enter a valid price."
            return
        }

        let parsedAmenities = amenitiesText
            .split(separator: ",")
            .map(String.init)

        Task {
            var updatedProperty = property
            updatedProperty.isListed = isListed

            await propertyVM.updateProperty(
                property: updatedProperty,
                title: title,
                details: details,
                rent: rentValue,
                bedrooms: bedrooms,
                bathrooms: bathrooms,
                category: category,
                locationName: locationName,
                pricingCadence: pricingCadence,
                amenities: parsedAmenities,
                maxGuests: category.supportsGuestCount ? maxGuests : nil,
                latitude: latitude,
                longitude: longitude,
                images: images
            )
        }
    }

    private func syncCategoryState(for category: RentalCategory) {
        if !category.allowedPricingCadences.contains(pricingCadence) {
            pricingCadence = category.defaultPricingCadence
        }

        if category.supportsGuestCount, maxGuests < 1 {
            maxGuests = 1
        }
    }
}
