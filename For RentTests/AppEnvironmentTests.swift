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
