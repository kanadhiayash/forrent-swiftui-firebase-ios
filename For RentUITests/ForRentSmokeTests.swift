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

    func test_landlordCanEditProfileAndResetDemo() {
        let app = launchDemoLandlord()

        app.tabBars.buttons["Account"].tap()
        XCTAssertTrue(app.collectionViews["account.screen"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.otherElements["account.identity"].label.contains("Marc Dubois"))

        app.buttons["account.personalDetails"].tap()
        XCTAssertTrue(app.collectionViews["personalDetails.screen"].waitForExistence(timeout: 8))

        let firstName = app.textFields["personalDetails.firstName"]
        XCTAssertTrue(firstName.waitForExistence(timeout: 3))
        firstName.clearAndTypeText("Marcus")
        app.buttons["personalDetails.save"].tap()

        XCTAssertTrue(app.collectionViews["account.screen"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.otherElements["account.identity"].label.contains("Marcus Dubois"))

        app.buttons["account.resetDemo"].tap()
        XCTAssertTrue(app.alerts["Reset demo data?"].waitForExistence(timeout: 3))
        app.alerts["Reset demo data?"].buttons["account.confirmReset"].firstMatch.tap()

        XCTAssertTrue(app.staticTexts["Demo data restored."].waitForExistence(timeout: 8))
        XCTAssertTrue(app.otherElements["account.identity"].label.contains("Marc Dubois"))
    }

    func test_personalDetailsPreventsInvalidSaveAndProtectsUnsavedChanges() {
        let app = launchDemoLandlord()

        app.tabBars.buttons["Account"].tap()
        XCTAssertTrue(app.collectionViews["account.screen"].waitForExistence(timeout: 8))
        app.buttons["account.personalDetails"].tap()
        XCTAssertTrue(app.collectionViews["personalDetails.screen"].waitForExistence(timeout: 8))

        let firstName = app.textFields["personalDetails.firstName"]
        XCTAssertTrue(firstName.waitForExistence(timeout: 3))
        firstName.clearAndTypeText("")

        let saveButton = app.buttons["personalDetails.save"]
        XCTAssertTrue(saveButton.isEnabled)
        saveButton.tap()

        let firstNameError = app.descendants(matching: .any)["personalDetails.firstNameError"]
        XCTAssertTrue(firstNameError.waitForExistence(timeout: 3))
        XCTAssertTrue(app.collectionViews["personalDetails.screen"].exists)

        firstName.clearAndTypeText("Marco")
        app.buttons["personalDetails.cancel"].tap()
        XCTAssertTrue(app.alerts["Discard changes?"].waitForExistence(timeout: 3))
        app.alerts["Discard changes?"].buttons["Keep Editing"].firstMatch.tap()
        XCTAssertTrue(app.collectionViews["personalDetails.screen"].exists)

        app.buttons["personalDetails.cancel"].tap()
        app.alerts["Discard changes?"].buttons["Discard Changes"].firstMatch.tap()
        XCTAssertTrue(app.collectionViews["account.screen"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.otherElements["account.identity"].label.contains("Marc Dubois"))
    }

    private func launchDemoLandlord() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Explore the demo"].waitForExistence(timeout: 8))
        app.buttons["Marc Dubois"].tap()
        XCTAssertTrue(app.tabBars.buttons["Properties"].waitForExistence(timeout: 8))

        return app
    }
}

private extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        tap()

        if let existingValue = value as? String, !existingValue.isEmpty {
            let deleteString = String(
                repeating: XCUIKeyboardKey.delete.rawValue,
                count: existingValue.count
            )
            typeText(deleteString)
        }

        if !text.isEmpty {
            typeText(text)
        }
    }
}
