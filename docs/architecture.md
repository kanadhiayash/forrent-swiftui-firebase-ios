# Architecture

For Rent uses a small MVVM structure that keeps SwiftUI views focused on rendering, view models focused on state and user actions, and services focused on Firebase and local persistence.

## App Entry

- `FourRent/FourRentApp.swift` configures Firebase and injects shared view models into the environment.
- `FourRent/Views/RootView.swift` routes users based on authentication state and role.
- `FourRent/ContentView.swift` remains the app's primary content wrapper.

## Layers

### Models

`FourRent/Models/` defines the app's core data contracts:

- `AppUser`: profile, role, contact details, and shortlist IDs.
- `Property`: listing details, location, landlord owner ID, listing state, and assigned state.
- `Request`: tenant-to-landlord request metadata.
- `RequestStatus`: pending, accepted, or rejected.
- `Enums`: user roles and shared enum definitions.

### View Models

`FourRent/ViewModels/` owns async user actions and screen state:

- `AuthViewModel`: registration, login, logout, guest mode, profile loading, and profile updates.
- `PropertyViewModel`: listed property browsing, landlord property inventory, create/update/delete/de-list actions.
- `RequestViewModel`: request listeners, request creation, and accept/reject updates.
- `ShortlistViewModel`: saved-property state, Firestore shortlist updates, and local cache.

### Services

`FourRent/Services/` wraps external and local persistence:

- `AuthService`: Firebase Auth calls.
- `FirestoreService`: Firestore queries, writes, listeners, and batched request/property updates.
- `UserDefaultsManager`: lightweight local state.
- `GoogleService-Info.example.plist`: safe Firebase plist template.

### Views

`FourRent/Views/` is organized by user journey:

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

Firebase-specific logic is concentrated in services and view models. Views should not directly construct Firestore writes. This keeps the UI easier to test and makes role/ownership rules easier to audit.
