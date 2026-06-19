# For Rent

**A SwiftUI rental marketplace prototype that connects landlord listing management, tenant discovery, rental requests, and shortlist workflows through Firebase Auth and Firestore.**

For Rent is an iOS portfolio project built to demonstrate product thinking, SwiftUI implementation, MVVM architecture, Firebase-backed persistence, and role-based app flows for a rental marketplace experience.

## Project Overview

For Rent supports three user contexts:

| User Type | Purpose |
| --- | --- |
| Guest | Browse available rentals before signing in. |
| Tenant | Browse properties, save favorites, and send rental requests. |
| Landlord | Create, manage, list/de-list, and review requests for owned properties. |

The project is intentionally scoped as a portfolio-grade iOS prototype, not a production App Store release. It focuses on clean flow wiring, data ownership, and understandable Firebase integration.

## Problem Statement

Rental marketplace apps require multiple workflows to stay synchronized: authentication, user roles, listing availability, saved properties, request status, and landlord approvals. If those concerns are handled only in the UI or scattered across views, users can see stale listings, duplicate requests, unclear permissions, or inconsistent state.

## Solution

For Rent uses a role-aware SwiftUI app structure backed by Firebase Authentication and Cloud Firestore. SwiftUI views render the experience, view models own user actions and state transitions, and service classes centralize Firebase operations. Firestore records model users, properties, requests, and tenant shortlists so major actions produce persisted state changes.

## Key Features

### Implemented

- Email/password authentication with Firebase Authentication.
- Tenant and landlord role selection during sign-up.
- Guest browsing flow for listed, unassigned properties.
- Role-based routing after login.
- Landlord property creation with rent, beds, baths, location, images, and listing status.
- Landlord-owned property filtering.
- Property editing, de-listing, re-listing, and deletion.
- Tenant browsing with search and max-rent filtering.
- Property detail screens with listing information, local images, map preview, and share action.
- Tenant shortlist/favorites using Firestore and local cache.
- Rental request creation with deterministic request IDs to reduce duplicates.
- Landlord request acceptance and rejection.
- Accepted requests update property availability by marking the property assigned and unlisted.
- Profile display and profile editing.
- Loading, empty, error, success, and confirmation states.
- Baseline Firestore security rules in `firestore.rules`.

### Planned

- Firebase Storage-backed listing images.
- Automated unit and UI tests.
- Firestore Emulator Suite validation for rules.
- Screenshots and demo GIF/video.
- More advanced listing filters.

## Product / User Flows

### Guest Flow

1. Open the app without signing in.
2. Continue as guest.
3. Browse listed and unassigned properties.
4. View property details.
5. Share a property.
6. Sign in as a tenant to save or request a property.

### Tenant Flow

1. Create an account or log in as a tenant.
2. Browse available rentals.
3. Search by text or filter by maximum rent.
4. Open a property detail page.
5. Save or remove the property from shortlist.
6. Send a rental request.
7. Track request status as pending, accepted, or rejected.
8. Update profile information.

### Landlord Flow

1. Create an account or log in as a landlord.
2. Add a rental property.
3. View only owned properties.
4. Edit listing details.
5. List, de-list, or delete a property.
6. Review incoming tenant requests.
7. Accept or reject pending requests.
8. Accepted requests remove the property from public browsing.

## Tech Stack

| Layer | Technology |
| --- | --- |
| Platform | iOS |
| UI | SwiftUI |
| Architecture | MVVM |
| Language | Swift |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Maps | MapKit |
| Media Picker | PhotosUI |
| Local Media Storage | FileManager |
| Lightweight Local State | UserDefaults |
| Dependency Management | Swift Package Manager |
| IDE Detected | Xcode 26.3 |
| iOS Deployment Target | iOS 18.0 |

Firebase packages are resolved through Swift Package Manager in `For Rent.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.

## Architecture Overview

The app follows MVVM with a small service layer:

| Layer | Responsibility |
| --- | --- |
| Views | Render SwiftUI screens, navigation, forms, and reusable components. |
| ViewModels | Own screen state, validation, role checks, async actions, and user-facing errors. |
| Services | Wrap Firebase Auth, Firestore reads/writes/listeners, local defaults, and image persistence. |
| Models | Define codable Firestore-backed app entities. |
| Utilities | Provide validation, extensions, and image helper logic. |

Primary view models:

- `AuthViewModel`: auth state, guest mode, registration, login, logout, profile updates.
- `PropertyViewModel`: property fetch, filtering, create, update, delete, and listing status.
- `RequestViewModel`: request listener, tenant request creation, landlord accept/reject.
- `ShortlistViewModel`: saved property state, Firestore sync, and local cache.

Primary services:

- `AuthService`: Firebase Auth wrapper.
- `FirestoreService`: Firestore users, properties, requests, shortlist operations, and listeners.
- `UserDefaultsManager`: local cached state.
- `ImageManager`: local image persistence.

Shared UI foundations are defined in `For Rent/DesignSystem/ForRentDesignTokens.swift`
and reusable components such as `ButtonStyles.swift` and `StatusChip.swift`.

## Folder Structure

```text
.
├── For Rent.xcodeproj/
├── For Rent/
│   ├── Assets.xcassets/
│   ├── DesignSystem/
│   │   └── ForRentDesignTokens.swift
│   ├── Models/
│   │   ├── AppUser.swift
│   │   ├── Enums.swift
│   │   ├── Property.swift
│   │   ├── Request.swift
│   │   └── RequestStatus.swift
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── FirestoreService.swift
│   │   ├── GoogleService-Info.example.plist
│   │   └── UserDefaultsManager.swift
│   ├── Utilities/
│   ├── ViewModels/
│   ├── Views/
│   │   ├── Auth/
│   │   ├── Components/
│   │   ├── Guest/
│   │   ├── Landlord/
│   │   ├── Shared/
│   │   └── Tenant/
│   ├── ContentView.swift
│   └── ForRentApp.swift
├── docs/
├── DESIGN.md
├── PRODUCT.md
├── firestore.rules
├── LICENSE
└── README.md
```

## Data Model / Backend Overview

For Rent uses Firebase Authentication for account identity and Cloud Firestore for app data.

### Firestore Collections

| Collection | Purpose |
| --- | --- |
| `users` | Stores profile fields, role, email, phone, and shortlisted property IDs. |
| `properties` | Stores listing details, owner ID, location, local image filenames, and listing/assignment state. |
| `requests` | Stores tenant requests, landlord/property references, tenant contact info, and request status. |

### Core Models

| Model | Key Fields |
| --- | --- |
| `AppUser` | `id`, `email`, `role`, `firstName`, `lastName`, `phone`, `shortlisted` |
| `Property` | `id`, `title`, `details`, `rent`, `bedrooms`, `bathrooms`, `latitude`, `longitude`, `imageNames`, `landlordId`, `isListed`, `isAssigned` |
| `Request` | `id`, `propertyId`, `landlordId`, `tenantId`, `tenantName`, `tenantPhone`, `status` |
| `RequestStatus` | `pending`, `accepted`, `rejected` |

### Backend Notes

- Tenant/guest browsing fetches properties where `isListed == true` and `isAssigned == false`.
- Landlord inventory fetches properties by `landlordId`.
- Request listeners are scoped by tenant ID or landlord ID.
- Request IDs use `{tenantId}_{propertyId}` to reduce duplicate requests for the same tenant/property pair.
- Accepting a request updates both the request status and property availability in a Firestore batch.
- Listing images are currently stored locally, not in Firebase Storage.

## Setup and Installation

### Requirements

- macOS with Xcode installed.
- Xcode 26.3 was detected in this local environment.
- iOS simulator support.
- Firebase project with Authentication and Firestore enabled.

### Clone

```bash
git clone https://github.com/kanadhiayash/forrent-swiftui-firebase-ios.git
cd forrent-swiftui-firebase-ios
```

### Firebase Setup

1. Create a Firebase project.
2. Add an iOS app with bundle ID:

```text
com.yashkanadhia.ForRent
```

3. Enable Email/Password Authentication.
4. Enable Cloud Firestore.
5. Download `GoogleService-Info.plist`.
6. Place the real plist here:

```text
For Rent/Services/GoogleService-Info.plist
```

7. Keep the real plist local. It is intentionally ignored by Git.
8. Use the included placeholder file only as a setup reference:

```text
For Rent/Services/GoogleService-Info.example.plist
```

9. Review `firestore.rules` before using a shared Firebase project.

## Environment Variables

No committed `.env` file is required for the current iOS app.

Firebase configuration is provided by `GoogleService-Info.plist`. The real file must not be committed. The example plist uses placeholder values such as:

```text
YOUR_FIREBASE_WEB_API_KEY
YOUR_GCM_SENDER_ID
YOUR_GOOGLE_APP_ID
your-firebase-project-id
```

## How to Run Locally

### Recommended: Xcode

1. Open `For Rent.xcodeproj`.
2. Wait for Swift Package Manager dependencies to resolve.
3. Confirm your local `GoogleService-Info.plist` is present.
4. Select an iOS simulator.
5. Build and run.

### Optional: Command-Line Build Check

```bash
xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

## Screenshots / Demo

Screenshots will be added after the final UI capture/export.

Planned screenshot paths:

```text
docs/assets/screenshots/login.png
docs/assets/screenshots/tenant-home.png
docs/assets/screenshots/property-detail.png
docs/assets/screenshots/shortlist.png
docs/assets/screenshots/landlord-properties.png
docs/assets/screenshots/requests.png
```

Demo media will be added after simulator capture.

Planned demo path:

```text
docs/assets/demo/for-rent-demo.gif
```

## Accessibility and UX Considerations

Implemented considerations:

- SwiftUI-native controls for forms, buttons, tabs, lists, and navigation.
- Role-specific navigation to reduce irrelevant actions.
- Empty/loading/error states for major async workflows.
- Confirmation prompts for destructive property deletion.
- Protected-action messaging when guests try tenant-only actions.
- Property card accessibility labels for clearer listing summaries.

Planned improvements:

- Full VoiceOver walkthrough across auth, tenant, landlord, and guest flows.
- Dynamic Type review on small devices.
- Color contrast audit after final visual polish.
- UI tests for key role-based flows.

## QA / Testing Notes

Current verification:

- Command-line simulator build has been validated with `CODE_SIGNING_ALLOWED=NO`.
- Firestore rules exist as a baseline in `firestore.rules`.

Manual QA checklist:

- Register and log in as a tenant.
- Register and log in as a landlord.
- Continue as guest.
- Add, edit, list/de-list, and delete a landlord property.
- Browse available listings as tenant and guest.
- Save and remove a tenant shortlist item.
- Send a tenant request.
- Accept and reject landlord requests.
- Confirm accepted requests update property availability.
- Edit profile details and confirm persistence.

Testing still needed:

- Unit tests for view models and validation.
- UI tests for tenant, landlord, and guest journeys.
- Firebase Emulator Suite tests for Firestore security rules.

## Known Limitations

- Real Firebase configuration is required locally and is not included in the repo.
- Property images are stored locally with `FileManager`; they do not sync across devices.
- Firebase Storage is not implemented.
- Automated test targets are not currently included.
- Firestore security rules need emulator validation before production use.
- Screenshots and demo media are placeholders.
- This is a portfolio prototype, not a production rental marketplace.

## Future Improvements / Roadmap

| Area | Planned Work |
| --- | --- |
| Media | Add Firebase Storage for cross-device listing images. |
| Testing | Add unit, UI, and Firestore emulator tests. |
| Search | Add bedroom, bathroom, location radius, and availability filters. |
| UX | Add polished screenshots, preview data, and demo capture. |
| Data | Add seed/demo data strategy for reviewer-friendly setup. |
| Operations | Document Firebase indexes if composite indexes are required. |

## Portfolio Case Study Angle

This project is a strong case study for:

- Designing role-based mobile workflows.
- Separating SwiftUI presentation from state and persistence logic.
- Modeling Firebase Auth identity separately from Firestore profile data.
- Enforcing ownership-aware data access in both app logic and Firestore rules.
- Turning a common marketplace concept into a reviewer-friendly iOS portfolio repo.

Suggested case study sections:

- Product problem and role map.
- Architecture and Firebase data model.
- Landlord request acceptance and property availability update flow.
- Public repo security decisions around Firebase config.
- Limitations and roadmap.

## Credits / Author

Built by **Yash Kanadhia**.

## License

This repository includes an MIT License. See [LICENSE](LICENSE).
