# For Rent GitHub Ready Checklist

## Public Repo Safety Checklist

- [x] Add `.gitignore`.
- [x] Ignore `GoogleService-Info.plist`.
- [x] Add `GoogleService-Info.example.plist`.
- [x] Document Firebase setup.
- [x] Document Firestore data model.
- [x] Avoid committing service account files or private keys.
- [x] Confirm real `GoogleService-Info.plist` is ignored after Git is initialized.
- [ ] Add screenshots.
- [x] Add MIT license.

## Files Safe To Commit

- Swift source files.
- Xcode project file.
- `README.md`.
- `docs/*.md`.
- `.gitignore`.
- `GoogleService-Info.example.plist`.
- Asset catalog metadata.
- `Package.resolved`.
- `firestore.rules`.

## Files That Must Not Be Committed

- `GoogleService-Info.plist`
- `.env`
- `*.p8`
- `*.pem`
- `*.key`
- service account JSON files
- `DerivedData/`
- `build/`
- `xcuserdata/`
- `.DS_Store`

## Recommended Repo Name

`forrent-swiftui-firebase-ios`

## Recommended Repo Description

A SwiftUI iOS rental marketplace app with Firebase Authentication, Firestore persistence, MVVM architecture, role-based landlord and tenant flows, property listings, requests, and shortlist management.

## Recommended GitHub Topics

- `swiftui`
- `ios`
- `firebase`
- `firestore`
- `mvvm`
- `rental-app`
- `property-management`
- `ios-development`
- `portfolio-project`

## Recommended Pinned Repo Description

For Rent is a SwiftUI rental app portfolio project demonstrating Firebase Auth, Firestore CRUD, MVVM, and role-based landlord/tenant workflows.

## Recommended Commit Sequence

1. `docs: add project audit and product brief`
2. `chore: add github safety files`
3. `fix: stabilize auth and role-based routing`
4. `fix: wire property and request firestore flows`
5. `feat: add search filters and safer protected actions`
6. `docs: upgrade readme and verification notes`

## Recommended Portfolio Case-Study Link Placeholder

`https://your-portfolio.com/forrent-swiftui-firebase-ios`
