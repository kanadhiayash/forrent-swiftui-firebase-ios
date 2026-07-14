import Foundation

enum ListingSortOption: String, CaseIterable, Identifiable {
    case recommended = "Recommended"
    case priceLowToHigh = "Price: low to high"
    case priceHighToLow = "Price: high to low"
    case bedrooms = "Most bedrooms"

    var id: String { rawValue }
}

struct ListingSearchState: Equatable {
    var searchText = ""
    var maxRentText = ""
    var selectedProvince = "All"
    var sortOption = ListingSortOption.recommended
    var visibleCount = 6

    func filteredProperties(from properties: [Property]) -> [Property] {
        let query = normalizedSearchText
        let rentLimit = maximumRent

        let filtered = properties.filter { property in
            let searchable = [
                property.title,
                property.details,
                property.resolvedLocationName,
                property.category.title,
                property.resolvedAmenities.joined(separator: " ")
            ]
                .joined(separator: " ")
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .lowercased()

            let matchesSearch = query.isEmpty || searchable.contains(query)
            let matchesRent = rentLimit.map { property.rent <= $0 } ?? true
            let matchesProvince = selectedProvince == "All" || province(for: property) == selectedProvince

            return matchesSearch && matchesRent && matchesProvince
        }

        switch sortOption {
        case .recommended:
            return filtered
        case .priceLowToHigh:
            return filtered.sorted {
                if $0.rent == $1.rent { return $0.title < $1.title }
                return $0.rent < $1.rent
            }
        case .priceHighToLow:
            return filtered.sorted {
                if $0.rent == $1.rent { return $0.title < $1.title }
                return $0.rent > $1.rent
            }
        case .bedrooms:
            return filtered.sorted {
                if $0.bedrooms == $1.bedrooms { return $0.rent < $1.rent }
                return $0.bedrooms > $1.bedrooms
            }
        }
    }

    func visibleProperties(from properties: [Property]) -> [Property] {
        Array(filteredProperties(from: properties).prefix(visibleCount))
    }

    func provinceOptions(for properties: [Property]) -> [String] {
        ["All"] + Set(properties.map(province(for:))).sorted()
    }

    mutating func resetPagination(defaultCount: Int = 6) {
        visibleCount = defaultCount
    }

    mutating func showMore(pageSize: Int = 6) {
        visibleCount += pageSize
    }

    func province(for property: Property) -> String {
        let components = property.resolvedLocationName
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard components.count > 1 else {
            return property.resolvedLocationName
        }

        return components[1]
    }

    private var normalizedSearchText: String {
        searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .lowercased()
    }

    private var maximumRent: Double? {
        let trimmedValue = maxRentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return nil }
        return Double(trimmedValue)
    }
}
