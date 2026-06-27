//
//  PropertyDetailView.swift
//  For Rent
//
//  Created by Yash Kanadhia on 2026-03-20.
//

import SwiftUI

struct PropertyDetailView: View {
    
    let property: Property
    let user: AppUser
    
    @EnvironmentObject var requestVM: RequestViewModel
    @EnvironmentObject var shortlistVM: ShortlistViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var protectedActionMessage: String?
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                propertyMedia

                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
                        Text(property.title)
                            .font(.title.bold())
                            .foregroundStyle(ForRentTheme.Colors.ink)

                        Label(property.resolvedLocationName, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(ForRentTheme.Colors.body)

                        Text("\(property.rent.toCurrency()) \(property.resolvedPricingCadence.shortLabel)")
                            .font(.title2.bold())
                            .foregroundStyle(ForRentTheme.Colors.primary)
                    }

                    HStack(spacing: ForRentTheme.Spacing.xs) {
                        detailFact("\(property.bedrooms) bedrooms", icon: "bed.double.fill")
                        detailFact("\(property.bathrooms) bathrooms", icon: "bathtub.fill")
                    }

                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
                        Text("About this rental")
                            .font(.headline)
                        Text(property.details)
                            .font(.body)
                            .foregroundStyle(ForRentTheme.Colors.body)
                    }

                    if !property.resolvedAmenities.isEmpty {
                        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
                            Text("Amenities")
                                .font(.headline)

                            ForEach(property.resolvedAmenities, id: \.self) { amenity in
                                Label(amenity, systemImage: "checkmark.circle.fill")
                                    .foregroundStyle(ForRentTheme.Colors.body)
                            }
                        }
                    }

                    Button {
                        guard authVM.user?.role == .tenant else {
                            protectedActionMessage = "Sign in as a renter to save this listing."
                            return
                        }

                        Task {
                            await shortlistVM.toggle(propertyId: property.id, userId: authVM.user?.id)
                        }
                    } label: {
                        Label(
                            shortlistVM.isSaved(property.id) ? "Saved" : "Save listing",
                            systemImage: shortlistVM.isSaved(property.id) ? "heart.fill" : "heart"
                        )
                    }
                    .secondaryButtonStyle()
                    .accessibilityLabel(shortlistVM.isSaved(property.id) ? "Remove from saved properties" : "Save property")

                    Button("Share listing", systemImage: "square.and.arrow.up") {
                        share()
                    }
                    .foregroundStyle(ForRentTheme.Colors.link)
                }
                .padding(ForRentTheme.Spacing.md)
            }
        }
        .safeAreaInset(edge: .bottom) {
            inquiryAction
        }
        .navigationTitle("Details")
        .task {
            requestVM.startListening(for: authVM.user ?? user)
        }
        .alert("Action requires sign in", isPresented: Binding(
            get: { protectedActionMessage != nil },
            set: { if !$0 { protectedActionMessage = nil } }
        )) {
            Button("Sign In") {
                authVM.requireAuthentication(for: property)
            }
            Button("Cancel", role: .cancel) {
                protectedActionMessage = nil
            }
        } message: {
            Text(protectedActionMessage ?? "")
        }
        .showError($requestVM.errorMessage)
        .showError($shortlistVM.errorMessage)
    }

    private var propertyMedia: some View {
        Group {
            if property.imageNames.isEmpty {
                ZStack {
                    ForRentTheme.Colors.surfaceSoft
                    VStack(spacing: ForRentTheme.Spacing.xs) {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                        Text("Property photos unavailable")
                            .font(.headline)
                    }
                    .foregroundStyle(ForRentTheme.Colors.muted)
                }
            } else {
                TabView {
                    ForEach(property.imageNames, id: \.self) { imageName in
                        ListingImageView(name: imageName) {
                            ZStack {
                                ForRentTheme.Colors.surfaceSoft
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(ForRentTheme.Colors.muted)
                            }
                        }
                            .clipped()
                    }
                }
                .tabViewStyle(.page)
            }
        }
        .frame(height: 280)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var inquiryAction: some View {
        VStack(spacing: ForRentTheme.Spacing.xs) {
            if user.role == .tenant {
                if let request = requestVM.requests.first(where: {
                    $0.propertyId == property.id && $0.tenantId == user.id
                }) {
                    StatusChip(
                        title: "Inquiry \(request.status.title.lowercased())",
                        systemImage: "bubble.left.and.text.bubble.right.fill",
                        tone: request.status == .accepted ? .success : .info
                    )
                } else {
                    Button("Request a viewing") {
                        Task {
                            await requestVM.sendRequest(property: property, user: user)
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(requestVM.isLoading)
                    .sensoryFeedback(.success, trigger: requestVM.successMessage)
                }
            } else if user.role == .guest {
                Button("Sign in to request a viewing") {
                    authVM.requireAuthentication(for: property)
                }
                .primaryButtonStyle()
            }
        }
        .padding(.horizontal, ForRentTheme.Spacing.md)
        .padding(.vertical, ForRentTheme.Spacing.sm)
        .background(.bar)
    }

    private func detailFact(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, ForRentTheme.Spacing.sm)
            .padding(.vertical, ForRentTheme.Spacing.xs)
            .background(ForRentTheme.Colors.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))
    }
    
    private func share() {
        let text = "\(property.title) - \(property.rent.toCurrency()) \(property.resolvedPricingCadence.shortLabel)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        root.present(activityVC, animated: true)
    }
}
