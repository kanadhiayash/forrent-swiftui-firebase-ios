import XCTest
@testable import For_Rent

final class AppUserDisplayTests: XCTestCase {
    func test_displayNameUsesFirstAndLastName() {
        let user = makeUser(firstName: "  Marc ", lastName: " Dubois  ")

        XCTAssertEqual(user.displayName, "Marc Dubois")
    }

    func test_initialsUseUpToTwoNameCharacters() {
        let user = makeUser(firstName: " marc", lastName: "dubois ")

        XCTAssertEqual(user.initials, "MD")
    }

    func test_emptyNameFallsBackToAccountAndFR() {
        let user = makeUser(firstName: "  ", lastName: "\n")

        XCTAssertEqual(user.displayName, "Account")
        XCTAssertEqual(user.initials, "FR")
    }

    func test_tenantRoleDisplaysAsRenter() {
        let user = makeUser(role: .tenant)

        XCTAssertEqual(user.roleDisplayName, "Renter")
    }

    func test_emptyPhoneReturnsNil() {
        let user = makeUser(phone: "  \n")

        XCTAssertNil(user.formattedPhoneForDisplay)
    }

    private func makeUser(
        role: UserRole = .landlord,
        firstName: String = "Marc",
        lastName: String = "Dubois",
        phone: String = "514-555-0112"
    ) -> AppUser {
        AppUser(
            id: "display-test-user",
            email: "marc.dubois@example.invalid",
            role: role,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            shortlisted: []
        )
    }
}
