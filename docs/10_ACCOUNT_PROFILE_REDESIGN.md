# Account And Profile Redesign

## Scope

This slice upgrades the shared Account surface for renter and landlord shells and replaces the legacy Profile and Edit Profile screens with one focused Personal Details flow.

The work stays inside the existing MVVM boundary:

- `AuthViewModel` owns authenticated and demo user state.
- `ProfileEditor` owns draft validation and save readiness.
- `AccountView` presents account actions and routes to focused flows.
- `PersonalDetailsView` edits only mutable profile fields.
- Shared account components remain presentation-only.

## User Experience

Account is now a durable role-shell destination instead of a generic profile screen. The page leads with identity, role, and verified contact information, then groups settings into clear task rows.

Personal Details is a focused full-screen flow:

- First and last name are required.
- Phone is optional but validated when present.
- Email is read-only in this slice.
- Invalid save attempts show inline field errors.
- Unsaved edits require explicit discard confirmation.
- Demo profile changes can be reset without leaving the Account tab.

## Accessibility And QA Notes

- Account identity, rows, Personal Details fields, inline errors, and destructive confirmations have stable accessibility identifiers for UI automation.
- Inline errors expose text and an accessibility identifier for field-level validation checks.
- The flow uses system `Form`, native alerts, and native navigation/sheet behavior so Dynamic Type, dark mode, Increase Contrast, and Reduce Motion remain system-aligned.
- The Personal Details save action is enabled for changed drafts and validates on tap, which lets users discover exact blocking fields instead of seeing a silent disabled state.

## Verification

Focused verification for this slice:

```bash
xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -parallel-testing-enabled NO \
  '-only-testing:For RentTests/ProfileEditorTests' \
  '-only-testing:For RentTests/AuthProfileUpdateTests' \
  '-only-testing:For RentTests/AppUserDisplayTests'

xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -parallel-testing-enabled NO \
  '-only-testing:For RentUITests/ForRentSmokeTests'

xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

The full PR gate remains the repo-required demo, Firebase, secret, build, and simulator test set before merge.
