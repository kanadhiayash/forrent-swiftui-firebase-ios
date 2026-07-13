import XCTest
@testable import For_Rent

@MainActor
final class AuthProfileUpdateTests: XCTestCase {
    func test_demoUpdateChangesProfileAndReturnsUpdatedUser() async throws {
        let seed = try demoSeed()
        let viewModel = AuthViewModel(environment: .demo(seed: seed))
        viewModel.selectDemoUser(id: seed.personas.landlord.id)

        let updated = try await viewModel.updateProfile(
            firstName: "  Marcus  ",
            lastName: "  Dubois  ",
            phone: "  514–555–0199  "
        )

        XCTAssertEqual(updated.firstName, "Marcus")
        XCTAssertEqual(updated.lastName, "Dubois")
        XCTAssertEqual(updated.phone, "514-555-0199")
        XCTAssertEqual(viewModel.user?.firstName, "Marcus")
        XCTAssertEqual(viewModel.user?.lastName, "Dubois")
        XCTAssertEqual(viewModel.user?.phone, "514-555-0199")
        XCTAssertNil(viewModel.successMessage)
    }

    func test_demoUpdateDoesNotChangeEmail() async throws {
        let seed = try demoSeed()
        let viewModel = AuthViewModel(environment: .demo(seed: seed))
        viewModel.selectDemoUser(id: seed.personas.landlord.id)
        let originalEmail = try XCTUnwrap(viewModel.user?.email)

        let updated = try await viewModel.updateProfile(
            firstName: "Marcus",
            lastName: "Dubois",
            phone: "514-555-0199"
        )

        XCTAssertEqual(updated.email, originalEmail)
        XCTAssertEqual(viewModel.user?.email, originalEmail)
    }

    func test_demoUpdateDoesNotChangeRole() async throws {
        let seed = try demoSeed()
        let viewModel = AuthViewModel(environment: .demo(seed: seed))
        viewModel.selectDemoUser(id: seed.personas.landlord.id)

        let updated = try await viewModel.updateProfile(
            firstName: "Marcus",
            lastName: "Dubois",
            phone: "514-555-0199"
        )

        XCTAssertEqual(updated.role, .landlord)
        XCTAssertEqual(viewModel.user?.role, .landlord)
    }

    func test_demoResetRestoresSeedProfile() async throws {
        let seed = try demoSeed()
        let viewModel = AuthViewModel(environment: .demo(seed: seed))
        viewModel.selectDemoUser(id: seed.personas.landlord.id)

        _ = try await viewModel.updateProfile(
            firstName: "Marcus",
            lastName: "Dubois",
            phone: "514-555-0199"
        )
        viewModel.resetDemo()

        XCTAssertEqual(viewModel.user?.firstName, seed.personas.landlord.firstName)
        XCTAssertEqual(viewModel.user?.lastName, seed.personas.landlord.lastName)
        XCTAssertEqual(viewModel.user?.phone, seed.personas.landlord.phone)
    }

    func test_emptyRequiredNamesFailBeforePersistence() async throws {
        let seed = try demoSeed()
        let store = RecordingProfileStore()
        let viewModel = AuthViewModel(
            environment: .firebase,
            profileStore: store,
            observesAuthState: false
        )
        viewModel.user = seed.personas.landlord

        do {
            _ = try await viewModel.updateProfile(
                firstName: " ",
                lastName: "Dubois",
                phone: "514-555-0199"
            )
            XCTFail("Expected required-name validation to fail.")
        } catch {
            XCTAssertEqual(error as? ProfileUpdateError, .requiredName)
        }

        XCTAssertEqual(store.updateCallCount, 0)
    }

    func test_firebaseFailurePreservesPreviousUser() async throws {
        let seed = try demoSeed()
        let original = seed.personas.landlord
        let viewModel = AuthViewModel(
            environment: .firebase,
            profileStore: FailingProfileStore(),
            observesAuthState: false
        )
        viewModel.user = original

        do {
            _ = try await viewModel.updateProfile(
                firstName: "Marcus",
                lastName: "Dubois",
                phone: "514-555-0199"
            )
            XCTFail("Expected the profile store to fail.")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Profile update failed.")
        }

        XCTAssertEqual(viewModel.user?.firstName, original.firstName)
        XCTAssertEqual(viewModel.user?.lastName, original.lastName)
        XCTAssertEqual(viewModel.user?.phone, original.phone)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_updateWithoutAuthenticatedUserThrows() async throws {
        let viewModel = AuthViewModel(
            environment: .firebase,
            profileStore: RecordingProfileStore(),
            observesAuthState: false
        )

        do {
            _ = try await viewModel.updateProfile(
                firstName: "Marc",
                lastName: "Dubois",
                phone: ""
            )
            XCTFail("Expected unauthenticated update to fail.")
        } catch {
            XCTAssertEqual(error as? ProfileUpdateError, .notAuthenticated)
        }
    }

    private func demoSeed() throws -> DemoSeed {
        let fixtureURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("For Rent")
            .appendingPathComponent("Resources")
            .appendingPathComponent("DemoSeed.json")
        return try DemoSeed.decode(data: Data(contentsOf: fixtureURL))
    }
}

private final class RecordingProfileStore: ProfileStore {
    private(set) var updateCallCount = 0

    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws {
        updateCallCount += 1
    }
}

private struct FailingProfileStore: ProfileStore {
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws {
        throw NSError(
            domain: "AuthProfileUpdateTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Profile update failed."]
        )
    }
}
