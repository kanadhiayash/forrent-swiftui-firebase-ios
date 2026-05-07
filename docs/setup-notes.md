# Setup Notes

## Requirements

- Xcode with iOS simulator support.
- A Firebase project.
- Firebase Authentication with Email/Password enabled.
- Cloud Firestore enabled.

## Firebase Setup

1. Create a Firebase project.
2. Add an iOS app with bundle ID `com.yashkanadhia.FourRent`.
3. Download `GoogleService-Info.plist`.
4. Place the real plist at `FourRent/Services/GoogleService-Info.plist`.
5. Keep the real plist local. It is intentionally ignored by Git.
6. Use `FourRent/Services/GoogleService-Info.example.plist` only as a public template.

## Firestore Setup

1. Review `firestore.rules`.
2. Test the rules with representative tenant and landlord accounts.
3. Deploy the rules only after validation.
4. Watch for Firebase console prompts for composite indexes during real query testing.

## Local Build

1. Open `FourRent.xcodeproj` in Xcode.
2. Wait for Swift Package Manager dependencies to resolve.
3. Select an iOS simulator.
4. Build and run from Xcode.

Command-line builds can also work when local Xcode tooling is configured, but Xcode is the preferred path because signing and simulator selection are visible.
