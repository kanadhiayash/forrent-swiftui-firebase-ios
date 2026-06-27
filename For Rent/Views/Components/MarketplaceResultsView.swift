import SwiftUI

enum ListingSortOption: String, CaseIterable, Identifiable {
    case recommended = "Recommended"
    case priceLowToHigh = "Price: low to high"
    case priceHighToLow = "Price: high to low"
    case bedrooms = "Most bedrooms"

    var id: String { rawValue }
}

struct MarketplaceResultsView: View {
    let properties: [Property]
    let user: AppUser

    @State private var searchText = ""
    @State private var maxRent = ""
    @State private var selectedProvince = "All"
    @State private var sortOption = ListingSortOption.recommended
    @State private var visibleCount = 6

    private let pageSize = 6

    var body: some View {
        ScrollView {
            LazyVStack(spacing: ForRentTheme.Spacing.md) {
                controls

                if filteredProperties.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else {
                    ForEach(Array(filteredProperties.prefix(visibleCount))) { property in
                        NavigationLink {
                            PropertyDetailView(property: property, user: user)
                        } label: {
                            PropertyCardView(property: property)
                        }
                        .buttonStyle(.plain)
                    }

                    if visibleCount < filteredProperties.count {
                        Button("Load more rentals") {
                            withAnimation(.easeOut(duration: ForRentTheme.Motion.standard)) {
                                visibleCount += pageSize
                            }
                        }
                        .secondaryButtonStyle()
                    }
                }
            }
            .padding()
        }
        .onChange(of: searchText) { _, _ in resetPagination() }
        .onChange(of: maxRent) { _, _ in resetPagination() }
        .onChange(of: selectedProvince) { _, _ in resetPagination() }
        .onChange(of: sortOption) { _, _ in resetPagination() }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text("Canada-wide rentals")
                .font(.title2.bold())

            HStack(spacing: ForRentTheme.Spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ForRentTheme.Colors.muted)
                TextField("City, province, or amenity", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Search rental listings")
            }
            .padding(ForRentTheme.Spacing.sm)
            .background(ForRentTheme.Colors.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))

            HStack(spacing: ForRentTheme.Spacing.sm) {
                TextField("Maximum rent", text: $maxRent)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Filter listings by maximum rent")

                Divider()

                Picker("Province", selection: $selectedProvince) {
                    ForEach(provinces, id: \.self) { province in
                        Text(province).tag(province)
                    }
                }
                .accessibilityLabel("Filter by province or territory")
            }
            .padding(ForRentTheme.Spacing.sm)
            .background(ForRentTheme.Colors.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))

            HStack {
                Text("\(filteredProperties.count) rentals")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(ForRentTheme.Colors.body)

                Spacer()

                Picker("Sort", selection: $sortOption) {
                    ForEach(ListingSortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .accessibilityLabel("Sort rentals")
            }
        }
    }

    private var filteredProperties: [Property] {
        let query = searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        let rentLimit = Double(maxRent.trimmingCharacters(in: .whitespacesAndNewlines))

        let filtered = properties.filter { property in
            let searchable = [
                property.title,
                property.details,
                property.resolvedLocationName,
                property.category.title,
                property.resolvedAmenities.joined(separator: " ")
            ]
                .joined(separator: " ")
                .lowercased()

            let matchesSearch = query.isEmpty || searchable.contains(query)
            let matchesRent = rentLimit.map { property.rent <= $0 } ?? true
            let matchesProvince = selectedProvince == "All" ||
                province(for: property) == selectedProvince

            return matchesSearch && matchesRent && matchesProvince
        }

        switch sortOption {
        case .recommended:
            return filtered
        case .priceLowToHigh:
            return filtered.sorted { $0.rent < $1.rent }
        case .priceHighToLow:
            return filtered.sorted { $0.rent > $1.rent }
        case .bedrooms:
            return filtered.sorted { $0.bedrooms > $1.bedrooms }
        }
    }

    private var provinces: [String] {
        ["All"] + Set(properties.map(province(for:))).sorted()
    }

    private func province(for property: Property) -> String {
        let components = property.resolvedLocationName
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        return components.count > 1 ? components[1] : property.resolvedLocationName
    }

    private func resetPagination() {
        visibleCount = pageSize
    }
}
