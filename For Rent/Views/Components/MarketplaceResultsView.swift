import SwiftUI

struct MarketplaceResultsView: View {
    let properties: [Property]
    let user: AppUser

    @State private var searchState = ListingSearchState()

    private let pageSize = 6

    var body: some View {
        ScrollView {
            LazyVStack(spacing: ForRentTheme.Spacing.md) {
                controls

                if filteredProperties.isEmpty {
                    ContentUnavailableView.search(text: searchState.searchText)
                } else {
                    ForEach(searchState.visibleProperties(from: properties)) { property in
                        NavigationLink {
                            PropertyDetailView(property: property, user: user)
                        } label: {
                            PropertyCardView(property: property)
                        }
                        .buttonStyle(.plain)
                    }

                    if searchState.visibleCount < filteredProperties.count {
                        Button("Load more rentals") {
                            withAnimation(.easeOut(duration: ForRentTheme.Motion.standard)) {
                                searchState.showMore(pageSize: pageSize)
                            }
                        }
                        .secondaryButtonStyle()
                    }
                }
            }
            .padding()
        }
        .onChange(of: searchState.searchText) { _, _ in resetPagination() }
        .onChange(of: searchState.maxRentText) { _, _ in resetPagination() }
        .onChange(of: searchState.selectedProvince) { _, _ in resetPagination() }
        .onChange(of: searchState.sortOption) { _, _ in resetPagination() }
    }

    private var controls: some View {
        VStack(alignment: .leading, spacing: ForRentTheme.Spacing.sm) {
            Text("Canada-wide rentals")
                .font(.title2.bold())

            HStack(spacing: ForRentTheme.Spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(ForRentTheme.Colors.muted)
                TextField("City, province, or amenity", text: $searchState.searchText)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Search rental listings")
            }
            .padding(ForRentTheme.Spacing.sm)
            .background(ForRentTheme.Colors.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: ForRentTheme.Radius.control))

            HStack(spacing: ForRentTheme.Spacing.sm) {
                TextField("Maximum rent", text: $searchState.maxRentText)
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Filter listings by maximum rent")

                Divider()

                Picker("Province", selection: $searchState.selectedProvince) {
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

                Picker("Sort", selection: $searchState.sortOption) {
                    ForEach(ListingSortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .accessibilityLabel("Sort rentals")
            }
        }
    }

    private var filteredProperties: [Property] {
        searchState.filteredProperties(from: properties)
    }

    private var provinces: [String] {
        searchState.provinceOptions(for: properties)
    }

    private func resetPagination() {
        searchState.resetPagination(defaultCount: pageSize)
    }
}
