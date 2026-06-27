import XCTest

final class ForRentSmokeTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func test_demoGuestCanOpenMarketplace() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Explore the demo"].waitForExistence(timeout: 8))

        let guestButton = app.buttons["Browse as guest"]
        XCTAssertTrue(guestButton.waitForExistence(timeout: 3))
        guestButton.tap()

        XCTAssertTrue(app.navigationBars["Browse Rentals"].waitForExistence(timeout: 8))
        let firstListing = app.buttons
            .matching(NSPredicate(format: "label CONTAINS %@", "King West Loft"))
            .firstMatch
        XCTAssertTrue(firstListing.waitForExistence(timeout: 8))
    }
}
