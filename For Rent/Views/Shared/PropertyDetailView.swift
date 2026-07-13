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

    private var presentation: ListingPresentation {
        ListingPresentation(property: property)
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                propertyMedia

                VStack(alignment: .leading, spacing: ForRentTheme.Spacing.lg) {
                    VStack(alignment: .leading, spacing: ForRentTheme.Spacing.xs) {
                        availabilityChip

                        Text(property.title)
                            .font(.title.bold())
                            .foregroundStyle(ForRentTheme.Colors.ink)

                        Label(property.resolvedLocationName, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(ForRentTheme.Colors.body)

                        Text(presentation.priceText)
                            .font(.title2.bold())
                            .foregroundStyle(ForRentTheme.Colors.primary)
                    }

                    detailFacts

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
                        Image(systemName: "building.2.crop.circle")
                            .font(.largeTitle)
                        Text("\(property.category.title) preview unavailable")
                            .font(.headline)
                        Text(property.resolvedLocationName)
                            .font(.subheadline)
                    }
                    .foregroundStyle(ForRentTheme.Colors.muted)
                }
            } else {
                imageCarousel
            }
        }
        .frame(height: 280)
        .accessibilityHidden(true)
    }

    private var imageCarousel: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(property.imageNames, id: \.self) { imageName in
                        propertyImage(named: imageName)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private func propertyImage(named imageName: String) -> some View {
        ListingImageView(name: imageName) {
            imagePlaceholder
        }
        .clipped()
    }

    private var imagePlaceholder: some View {
        ZStack {
            ForRentTheme.Colors.surfaceSoft
            VStack(spacing: ForRentTheme.Spacing.xs) {
                Image(systemName: "photo")
                    .font(.largeTitle)
                Text("Image unavailable")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(ForRentTheme.Colors.muted)
        }
    }

    private var detailFacts: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 142), spacing: ForRentTheme.Spacing.xs)],
            alignment: .leading,
            spacing: ForRentTheme.Spacing.xs
        ) {
            ForEach(presentation.compareFacts) { fact in
                detailFact(fact.title, icon: fact.systemImage)
            }
        }
    }

    @ViewBuilder
    private var availabilityChip: some View {
        if let request = activeRequest {
            StatusChip(
                title: "Inquiry \(request.status.title.lowercased())",
                systemImage: "bubble.left.and.text.bubble.right.fill",
                tone: request.status == .accepted ? .success : .info
            )
        } else {
            StatusChip(
                title: presentation.availabilityTitle,
                systemImage: presentation.availabilityIcon,
                tone: presentation.availabilityTone
            )
        }
    }

    @ViewBuilder
    private var inquiryAction: some View {
        VStack(spacing: ForRentTheme.Spacing.xs) {
            if user.role == .tenant {
                if let request = activeRequest {
                    StatusChip(
                        title: "Inquiry \(request.status.title.lowercased())",
                        systemImage: "bubble.left.and.text.bubble.right.fill",
                        tone: request.status == .accepted ? .success : .info
                    )
                } else {
                    Button(presentation.primaryActionTitle(for: user.role)) {
                        Task {
                            await requestVM.sendRequest(property: property, user: user)
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(requestVM.isLoading || !property.isListed || property.isAssigned)
                    .sensoryFeedback(.success, trigger: requestVM.successMessage)
                }
            } else if user.role == .guest {
                Button(presentation.primaryActionTitle(for: user.role)) {
                    authVM.requireAuthentication(for: property)
                }
                .primaryButtonStyle()
            }
        }
        .padding(.horizontal, ForRentTheme.Spacing.md)
        .padding(.vertical, ForRentTheme.Spacing.sm)
        .background(.bar)
    }

    private var activeRequest: Request? {
        requestVM.requests.first {
            $0.propertyId == property.id && $0.tenantId == user.id
        }
    }

    private func detailFact(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.medium))
            .lineLimit(1)
            .minimumScaleFactor(0.88)
            .padding(.horizontal, ForRentTheme.Spacing.sm)
            .padding(.vertical, ForRentTheme.Spacing.xs)
            .background(ForRentTheme.Colors.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))
    }
    
    private func share() {
        let text = "\(property.title) - \(presentation.priceText)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        root.present(activityVC, animated: true)
    }
}
