# For Rent

For Rent is a SwiftUI long-term rental marketplace for Canadian renters,
landlords, and guests. The current branch adds deterministic offline demo data,
Firebase-backed clean mode, guarded listing and inquiry operations, shared
feedback components, and automated quality gates.

This repository is an implementation project and does not claim an App Store
release or deployed production backend.

## Demo switch

`For Rent/Resources/DemoSeed.json` is the only demo-mode switch.

- Present: the app opens with 12 deterministic Canadian listings and guest,
  renter, and landlord walkthroughs.
- Deleted: the app selects clean Firebase mode. No demo accounts, records, or
  chooser are loaded.

Demo mutations stay in memory and reset on relaunch. The profile and guest
toolbars also provide a Reset Demo action. Demo records are never uploaded to
Firebase.

To verify clean mode locally, temporarily move the fixture, build, and restore
it:

```bash
mv "For Rent/Resources/DemoSeed.json" /tmp/DemoSeed.json
xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO
mv /tmp/DemoSeed.json "For Rent/Resources/DemoSeed.json"
```

## Product capabilities

- Canada-wide public rental discovery with search and maximum-rent filtering.
- Guest browsing with protected actions that preserve listing context.
- Renter saved listings and viewing inquiries.
- Landlord listing creation, editing, publishing, pausing, and inquiry review.
- CAD pricing cadence, public location, amenities, availability, and lifecycle
  migration through `ListingV2`.
- Typed inquiry lifecycle through `InquiryStatus`.
- Firebase Auth, Firestore, Storage, callable Functions, and App Check.
- Centralized toast feedback, inline validation, service errors, native alerts,
  skeleton states, and explicit empty states.
- Booking palette with Apple-native SwiftUI controls, Dynamic Type, haptics,
  Reduce Motion support, and 100 to 250 ms state motion.

Private addresses and exact occupied-property coordinates are not displayed.
The demo does not contain passwords, routable emails, real verification claims,
ratings, scarcity claims, or real personal data.

## Architecture

The app uses feature-oriented MVVM:

- Views render role-specific journeys and shared components.
- View models own validation, async state, and user actions.
- `AppEnvironment` selects demo repositories or Firebase services at startup.
- `DemoSession` owns deterministic in-memory demo mutations.
- Firebase services own Auth, Firestore, Storage, and callable Function access.

Saved listings live under `users/{uid}/savedListings/{listingId}`. Publishing a
listing and changing inquiry status use callable Functions. Security rules block
role escalation and direct inquiry-state updates.

## Firebase setup

1. Create a Firebase project for bundle ID `com.yashkanadhia.ForRent`.
2. Enable Email/Password Auth, Firestore, Storage, Functions, and App Check.
3. Copy the real plist to `For Rent/Services/GoogleService-Info.plist`.
4. Keep it local. The real plist is ignored and must never be committed.
5. Review and test `firestore.rules` and `storage.rules` before deployment.

The committed `GoogleService-Info.example.plist` contains placeholders only.
No Firebase rules, indexes, Functions, or configuration are deployed by this
repository automatically.

## Verification

```bash
npm ci
npm run validate:demo
npm run test:firebase
npm run scan:secrets

xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest" \
  -parallel-testing-enabled NO
```

GitHub Actions defines these stable checks:

- `build-ios-simulator`
- `unit-tests`
- `ui-smoke-tests`
- `firebase-emulator-tests`
- `secrets-hygiene`
- `demo-fixture-validation`

Remote branch and tag rules are documented in
`docs/GITHUB_PROTECTION.md`. Applying rulesets, pushing, merging, deploying
Firebase resources, tagging, and releasing remain owner-approved actions.

## Local Zeref OS

The optional `.zeref/` clone is ignored. The tested commit and privacy-first
setup are recorded in `docs/ZEREF_OS_SETUP.md`.

## Documentation

- `DESIGN.md`: visual and interaction system
- `PRODUCT.md`: scope and product principles
- `docs/architecture.md`: boundaries and data flow
- `docs/05_TESTING_AND_VERIFICATION.md`: evidence and QA matrix
- `docs/GITHUB_PROTECTION.md`: required remote repository settings
