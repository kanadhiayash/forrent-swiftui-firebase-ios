# Architecture

For Rent uses a small MVVM structure that keeps SwiftUI views focused on rendering, view models focused on state and user actions, and services focused on Firebase and local persistence.

## App Entry

- `For Rent/ForRentApp.swift` resolves `AppEnvironment`, configures Firebase only
  in clean mode, and injects shared view models.
- `For Rent/Services/AppEnvironment.swift` treats the optional bundled
  `DemoSeed.json` fixture as the single demo switch.
- `For Rent/ContentView.swift` remains the app's primary content wrapper.

## Layers

### Models

`For Rent/Models/` defines the app's core data contracts:

- `AppUser`: profile, role, contact details, and shortlist IDs.
- `Property`: listing details, location, landlord owner ID, listing state, and assigned state.
- `Request`: tenant-to-landlord request metadata.
- `RequestStatus`: submitted, acknowledged, viewing scheduled, accepted,
  rejected, cancelled, or expired.
- `ListingV2`: versioned Canada-aware listing contract and legacy migration.
- `Inquiry`: typed long-form inquiry lifecycle and allowed state transitions.
- `Enums`: user roles and shared enum definitions.

### View Models

`For Rent/ViewModels/` owns async user actions and screen state:

- `AuthViewModel`: registration, login, logout, guest mode, profile loading, and profile updates.
- `PropertyViewModel`: listed property browsing, landlord property inventory, create/update/delete/de-list actions.
- `RequestViewModel`: inquiry listeners, creation, role-aware state transitions,
  and optimistic rollback.
- `ShortlistViewModel`: saved-property state, Firestore shortlist updates, and local cache.

### Services

`For Rent/Services/` wraps external and local persistence:

- `AuthService`: Firebase Auth calls.
- `FirestoreService`: Firestore queries, writes, listeners, saved-listing
  subcollections, and callable Functions.
- `ListingMediaService`: Firebase Storage upload, download URL, and deletion.
- `DemoSession`: in-memory demo records and deterministic reset.
- `UserDefaultsManager`: lightweight local state.
- `GoogleService-Info.example.plist`: safe Firebase plist template.

### Views

`For Rent/Views/` is organized by user journey:

- `Auth/`: login, sign-up, and auth selection.
- `Guest/`: guest property browsing.
- `Tenant/`: tenant tabs, browse, and shortlist flows.
- `Landlord/`: landlord tabs, add/update property, and owned listings.
- `Shared/`: profile, request list, property card, property detail, and shortlist UI.
- `Components/`: reusable loading, error, image picker, map, and state views.

## Data Flow

1. SwiftUI view triggers a user action.
2. View model validates input and updates loading/error state.
3. Service performs Firebase or local persistence work.
4. View model publishes updated model state.
5. SwiftUI re-renders from published state.

## Firebase Boundary

Firebase-specific logic is concentrated in services and view models. Views do
not construct Firestore writes. Listing publication and inquiry transitions go
through callable Functions; Firestore rules deny direct inquiry updates and
role escalation. Firebase Storage paths are resolved by `ListingImageView`.

When the fixture is absent, the same app target compiles and launches in clean
Firebase mode. No Xcode project change or remote cleanup is required.
