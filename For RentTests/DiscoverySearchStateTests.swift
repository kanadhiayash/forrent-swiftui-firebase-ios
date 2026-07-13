import XCTest
@testable import For_Rent

final class DiscoverySearchStateTests: XCTestCase {
    func test_filtersListingsByQueryProvinceCategoryAndMaximumRent() {
        var state = ListingSearchState()
        state.searchText = " bike "
        state.maxRentText = "2500"
        state.selectedProvince = "British Columbia"

        let results = state.filteredProperties(from: fixtures)

        XCTAssertEqual(results.map(\.id), ["vancouver"])
    }

    func test_invalidMaximumRentDoesNotHideResults() {
        var state = ListingSearchState()
        state.maxRentText = "two thousand"

        let results = state.filteredProperties(from: fixtures)

        XCTAssertEqual(results.map(\.id), ["toronto", "vancouver", "halifax"])
    }

    func test_sortOptionsAreStableAndReadable() {
        var state = ListingSearchState()

        state.sortOption = .priceLowToHigh
        XCTAssertEqual(state.filteredProperties(from: fixtures).map(\.id), ["halifax", "vancouver", "toronto"])

        state.sortOption = .priceHighToLow
        XCTAssertEqual(state.filteredProperties(from: fixtures).map(\.id), ["toronto", "vancouver", "halifax"])

        state.sortOption = .bedrooms
        XCTAssertEqual(state.filteredProperties(from: fixtures).map(\.id), ["halifax", "toronto", "vancouver"])
    }

    func test_provinceOptionsRemoveCountryAndSort() {
        let state = ListingSearchState()

        XCTAssertEqual(
            state.provinceOptions(for: fixtures),
            ["All", "British Columbia", "Nova Scotia", "Ontario"]
        )
    }

    func test_visibleResultsRespectPagination() {
        var state = ListingSearchState(visibleCount: 2)

        XCTAssertEqual(state.visibleProperties(from: fixtures).map(\.id), ["toronto", "vancouver"])

        state.showMore(pageSize: 2)

        XCTAssertEqual(state.visibleProperties(from: fixtures).map(\.id), ["toronto", "vancouver", "halifax"])
    }
}

private extension DiscoverySearchStateTests {
    var fixtures: [Property] {
        [
            property(
                id: "toronto",
                title: "King West Loft",
                details: "Downtown balcony with transit access",
                rent: 3_200,
                bedrooms: 1,
                bathrooms: 1,
                category: .personalLiving,
                locationName: "Toronto, Ontario, Canada",
                amenities: ["Balcony", "Transit"]
            ),
            property(
                id: "vancouver",
                title: "Mount Pleasant Studio",
                details: "Compact studio near bike lanes",
                rent: 2_150,
                bedrooms: 0,
                bathrooms: 1,
                category: .personalLiving,
                locationName: "Vancouver, British Columbia, Canada",
                amenities: ["Bike storage", "Laundry"]
            ),
            property(
                id: "halifax",
                title: "Harbour Family House",
                details: "Detached home with workspace",
                rent: 1_950,
                bedrooms: 3,
                bathrooms: 2,
                category: .personalLiving,
                locationName: "Halifax, Nova Scotia, Canada",
                amenities: ["Parking", "Storage"]
            )
        ]
    }

    func property(
        id: String,
        title: String,
        details: String,
        rent: Double,
        bedrooms: Int,
        bathrooms: Int,
        category: RentalCategory,
        locationName: String,
        amenities: [String]
    ) -> Property {
        Property(
            id: id,
            title: title,
            details: details,
            rent: rent,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            latitude: 43.65,
            longitude: -79.38,
            imageNames: [],
            landlordId: "landlord",
            isListed: true,
            isAssigned: false,
            category: category,
            locationName: locationName,
            pricingCadence: .monthly,
            amenities: amenities
        )
    }
}
