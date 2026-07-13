import XCTest
@testable import For_Rent

@MainActor
final class ProfileEditorTests: XCTestCase {
    private let user = AppUser(
        id: "landlord-demo",
        email: "marc.dubois@example.invalid",
        role: .landlord,
        firstName: "Marc",
        lastName: "Dubois",
        phone: "514-555-0112",
        shortlisted: []
    )

    func test_initialDraftMatchesUserAndHasNoChanges() {
        let editor = ProfileEditor(user: user)

        XCTAssertEqual(editor.draft.firstName, "Marc")
        XCTAssertEqual(editor.draft.lastName, "Dubois")
        XCTAssertEqual(editor.draft.phone, "514-555-0112")
        XCTAssertFalse(editor.hasChanges)
        XCTAssertFalse(editor.canSave)
    }

    func test_whitespaceOnlyNameIsInvalid() {
        let editor = ProfileEditor(user: user)
        editor.draft.firstName = "   "

        XCTAssertFalse(editor.validate())
        XCTAssertEqual(editor.errors.firstName, "Enter a first name.")
        XCTAssertFalse(editor.canSave)
    }

    func test_validEditEnablesSave() {
        let editor = ProfileEditor(user: user)
        editor.draft.firstName = "Marcus"

        XCTAssertTrue(editor.canSave)
    }

    func test_unchangedNormalizedValuesDoNotEnableSave() {
        let editor = ProfileEditor(user: user)
        editor.draft.firstName = "  Marc  "
        editor.draft.phone = "  514-555-0112  "

        XCTAssertFalse(editor.hasChanges)
        XCTAssertFalse(editor.canSave)
    }

    func test_emptyPhoneIsAllowed() {
        let editor = ProfileEditor(user: user)
        editor.draft.phone = ""

        XCTAssertTrue(editor.validate())
        XCTAssertNil(editor.errors.phone)
        XCTAssertTrue(editor.canSave)
    }

    func test_phoneRejectsUnsupportedCharacters() {
        let editor = ProfileEditor(user: user)
        editor.draft.phone = "514-555-CALL"

        XCTAssertFalse(editor.validate())
        XCTAssertEqual(editor.errors.phone, "Use digits and common phone punctuation only.")
    }

    func test_phoneRequiresSevenToFifteenDigitsWhenPresent() {
        let editor = ProfileEditor(user: user)
        editor.draft.phone = "123"

        XCTAssertFalse(editor.validate())
        XCTAssertEqual(editor.errors.phone, "Enter a phone number with 7 to 15 digits.")

        editor.draft.phone = "1234567890123456"
        XCTAssertFalse(editor.validate())
        XCTAssertEqual(editor.errors.phone, "Enter a phone number with 7 to 15 digits.")
    }

    func test_beginSavingDisablesSave() {
        let editor = ProfileEditor(user: user)
        editor.draft.firstName = "Marcus"

        editor.beginSaving()

        XCTAssertTrue(editor.isSaving)
        XCTAssertFalse(editor.canSave)
    }

    func test_finishSavingResetsDirtyState() {
        let editor = ProfileEditor(user: user)
        editor.draft.firstName = "  Marcus  "
        editor.beginSaving()

        var updatedUser = user
        updatedUser.firstName = "Marcus"
        editor.finishSaving(user: updatedUser)

        XCTAssertEqual(editor.draft.firstName, "Marcus")
        XCTAssertFalse(editor.hasChanges)
        XCTAssertFalse(editor.isSaving)
    }

    func test_failurePreservesDraft() {
        let editor = ProfileEditor(user: user)
        editor.draft.firstName = "Marcus"
        let error = NSError(
            domain: "ProfileEditorTests",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "Save failed."]
        )

        editor.fail(error)

        XCTAssertEqual(editor.draft.firstName, "Marcus")
        XCTAssertEqual(editor.submissionState, .failed(message: "Save failed."))
        XCTAssertTrue(editor.hasChanges)
    }
}
