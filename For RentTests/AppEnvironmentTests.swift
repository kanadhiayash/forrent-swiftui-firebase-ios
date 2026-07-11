import XCTest
@testable import For_Rent

final class AppEnvironmentTests: XCTestCase {
    func test_demoSeedDecodesRequiredFixtureSlice() throws {
        let seed = try DemoSeed.decode(data: fixtureData())

        XCTAssertEqual(seed.personas.guest.id, "demo-guest")
        XCTAssertEqual(seed.personas.guest.role, .guest)
        XCTAssertEqual(seed.personas.tenant.id, "demo-tenant-olivia")
        XCTAssertEqual(seed.personas.tenant.role, .tenant)
        XCTAssertEqual(seed.personas.landlord.id, "demo-landlord-marc")
        XCTAssertEqual(seed.personas.landlord.role, .landlord)
        XCTAssertEqual(seed.properties.count, 12)
        XCTAssertTrue(seed.properties.allSatisfy { $0.resolvedLocationName.contains(", Canada") })
        XCTAssertEqual(seed.personas.tenant.shortlisted, ["listing-toronto-loft", "listing-vancouver-studio", "listing-halifax-flat"])
        XCTAssertEqual(Set(seed.requests.map(\.status)), Set(RequestStatus.allCases))
    }

    @MainActor
    func test_environmentUsesDemoModeWhenFixtureExists() async throws {
        let environment = try AppEnvironment.detect {
            try fixtureData()
        }

        XCTAssertTrue(environment.isDemo)
        XCTAssertEqual(environment.demoSession?.properties.count, 12)
    }

    func test_environmentUsesFirebaseModeWhenFixtureMissing() throws {
        let environment = try AppEnvironment.detect {
            nil
        }

        XCTAssertTrue(environment.isFirebase)
        XCTAssertNil(environment.demoSession)
    }

    func test_signupValidationRejectsDocumentedInvalidInputs() throws {
        XCTAssertThrowsError(try Validators.validateSignup(
            email: "",
            password: "secret1",
            confirmPassword: "secret1",
            firstName: "Olivia",
            lastName: "Chen"
        )) { error in
            XCTAssertEqual(error as? AppError, .emptyFields)
        }

        XCTAssertThrowsError(try Validators.validateSignup(
            email: "tenant.example.invalid",
            password: "secret1",
            confirmPassword: "secret1",
            firstName: "Olivia",
            lastName: "Chen"
        )) { error in
            XCTAssertEqual(error as? AppError, .invalidEmail)
        }

        XCTAssertThrowsError(try Validators.validateSignup(
            email: "tenant@example.invalid",
            password: "short",
            confirmPassword: "short",
            firstName: "Olivia",
            lastName: "Chen"
        )) { error in
            XCTAssertEqual(error as? AppError, .weakPassword)
        }

        XCTAssertThrowsError(try Validators.validateSignup(
            email: "tenant@example.invalid",
            password: "secret1",
            confirmPassword: "secret2",
            firstName: "Olivia",
            lastName: "Chen"
        )) { error in
            XCTAssertEqual(error as? AppError, .passwordMismatch)
        }

        XCTAssertNoThrow(try Validators.validateSignup(
            email: "tenant@example.invalid",
            password: "secret1",
            confirmPassword: "secret1",
            firstName: "Olivia",
            lastName: "Chen"
        ))
    }

    @MainActor
    func test_authViewModelSelectsDemoAccountWithoutFirebaseCredentials() async throws {
        let seed = try DemoSeed.decode(data: fixtureData())
        let authViewModel = AuthViewModel(environment: .demo(seed: seed))

        XCTAssertFalse(authViewModel.isAuthenticated)

        authViewModel.selectDemoUser(id: seed.personas.landlord.id)

        XCTAssertEqual(authViewModel.user?.id, seed.personas.landlord.id)
        XCTAssertEqual(authViewModel.user?.role, .landlord)
    }

    @MainActor
    func test_propertyViewModelFiltersAvailableDemoListings() async throws {
        let seed = try DemoSeed.decode(data: fixtureData())
        let propertyViewModel = PropertyViewModel(environment: .demo(seed: seed))

        await propertyViewModel.fetchProperties(for: seed.personas.tenant)

        let bikeListings = propertyViewModel.filteredAvailableProperties(
            searchText: "bike",
            maxRent: nil
        )
        let lowerRentListings = propertyViewModel.filteredAvailableProperties(
            searchText: "  canada  ",
            maxRent: 2_000
        )

        XCTAssertEqual(bikeListings.map(\.id), ["listing-vancouver-studio"])
        XCTAssertTrue(lowerRentListings.allSatisfy { $0.rent <= 2_000 })
        XCTAssertFalse(lowerRentListings.contains { $0.isAssigned || !$0.isListed })
    }

    @MainActor
    func test_requestViewModelBlocksGuestAndDuplicateRequests() async throws {
        let seed = try DemoSeed.decode(data: fixtureData())
        let requestViewModel = RequestViewModel(environment: .demo(seed: seed))
        let existingRequestProperty = try XCTUnwrap(seed.properties.first {
            $0.id == "listing-toronto-loft"
        })

        await requestViewModel.sendRequest(
            property: existingRequestProperty,
            user: seed.personas.guest
        )
        XCTAssertEqual(
            requestViewModel.errorMessage,
            "Please sign in as a tenant to send rental requests."
        )

        requestViewModel.startListening(for: seed.personas.tenant)
        await requestViewModel.sendRequest(
            property: existingRequestProperty,
            user: seed.personas.tenant
        )

        XCTAssertEqual(
            requestViewModel.errorMessage,
            "You already sent a request for this property."
        )
    }

    @MainActor
    func test_demoAcceptRequestAssignsAndUnlistsProperty() async throws {
        let seed = try DemoSeed.decode(data: fixtureData())
        let environment = AppEnvironment.demo(seed: seed)
        let propertyViewModel = PropertyViewModel(environment: environment)
        let requestViewModel = RequestViewModel(environment: environment)

        requestViewModel.startListening(for: seed.personas.landlord)
        let request = try XCTUnwrap(requestViewModel.requests.first {
            $0.id == "demo-tenant-olivia_listing-calgary-suite"
        })

        await requestViewModel.accept(request, currentUser: seed.personas.landlord)
        await propertyViewModel.fetchProperties(for: seed.personas.landlord)

        XCTAssertEqual(
            requestViewModel.requests.first { $0.id == request.id }?.status,
            .accepted
        )

        let assignedProperty = try XCTUnwrap(propertyViewModel.properties.first {
            $0.id == "listing-calgary-suite"
        })
        XCTAssertTrue(assignedProperty.isAssigned)
        XCTAssertFalse(assignedProperty.isListed)
    }

    @MainActor
    func test_shortlistToggleRemovesAndRestoresDemoListing() async throws {
        let seed = try DemoSeed.decode(data: fixtureData())
        let shortlistViewModel = ShortlistViewModel(environment: .demo(seed: seed))
        let userId = seed.personas.tenant.id
        let propertyId = "listing-toronto-loft"

        await shortlistViewModel.loadFromFirestore(userId: userId)
        XCTAssertTrue(shortlistViewModel.isSaved(propertyId))

        await shortlistViewModel.toggle(propertyId: propertyId, userId: userId)
        XCTAssertFalse(shortlistViewModel.isSaved(propertyId))

        await shortlistViewModel.toggle(propertyId: propertyId, userId: userId)
        XCTAssertTrue(shortlistViewModel.isSaved(propertyId))
    }

    @MainActor
    func test_demoResetRestoresFixtureBackedViewModelStateDeterministically() async throws {
        let seed = try DemoSeed.decode(data: fixtureData())
        let environment = AppEnvironment.demo(seed: seed)
        let authViewModel = AuthViewModel(environment: environment)
        let shortlistViewModel = ShortlistViewModel(environment: environment)
        let propertyViewModel = PropertyViewModel(environment: environment)
        let requestViewModel = RequestViewModel(environment: environment)

        authViewModel.selectDemoUser(id: seed.personas.tenant.id)
        let selectedUser = try XCTUnwrap(authViewModel.user)

        await shortlistViewModel.loadFromFirestore(userId: selectedUser.id)
        await propertyViewModel.fetchProperties(for: selectedUser)
        requestViewModel.startListening(for: selectedUser)

        let savedBeforeReset = shortlistViewModel.shortlistedIds
        let propertyBeforeReset = try XCTUnwrap(propertyViewModel.properties.first(where: { $0.id == "listing-toronto-loft" }))
        let requestBeforeResetCount = requestViewModel.requests.count

        await shortlistViewModel.toggle(propertyId: "listing-montreal-flat", userId: selectedUser.id)
        await propertyViewModel.setListing(propertyBeforeReset, isListed: false, currentUser: seed.personas.landlord)

        let freshRequestProperty = try XCTUnwrap(seed.properties.first(where: { $0.id == "listing-winnipeg-house" }))
        await requestViewModel.sendRequest(property: freshRequestProperty, user: selectedUser)

        XCTAssertNotEqual(shortlistViewModel.shortlistedIds, savedBeforeReset)
        XCTAssertEqual(propertyViewModel.properties.first(where: { $0.id == propertyBeforeReset.id })?.isListed, false)
        XCTAssertEqual(requestViewModel.requests.count, requestBeforeResetCount + 1)

        authViewModel.resetDemo()
        await shortlistViewModel.loadFromFirestore(userId: selectedUser.id)
        await propertyViewModel.fetchProperties(for: selectedUser)
        requestViewModel.startListening(for: selectedUser)

        XCTAssertEqual(authViewModel.user?.id, selectedUser.id)
        XCTAssertEqual(shortlistViewModel.shortlistedIds, savedBeforeReset)
        XCTAssertEqual(propertyViewModel.properties.first(where: { $0.id == propertyBeforeReset.id })?.isListed, propertyBeforeReset.isListed)
        XCTAssertEqual(requestViewModel.requests.count, requestBeforeResetCount)
    }
}

private extension AppEnvironmentTests {
    func fixtureData() throws -> Data {
        try Data(contentsOf: fixtureURL())
    }

    func fixtureURL() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("For Rent")
            .appendingPathComponent("Resources")
            .appendingPathComponent("DemoSeed.json")
    }
}
