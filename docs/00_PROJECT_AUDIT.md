# For Rent Project Audit

## Executive Summary

The detected project is an iOS SwiftUI app named `For Rent` at the code and Xcode target level. The intended public product name is now **For Rent**. The app already had the right portfolio concept: role-based landlord, tenant, and guest rental flows backed by Firebase Authentication and Firestore. Before the upgrade, the app compiled conceptually but had several portfolio-critical wiring gaps: no durable auth-state restoration, weak validation, force-unwrapped users in tenant flows, unfiltered landlord properties, incomplete delete/de-list behavior, request writes hidden behind `try?`, non-persisted profile updates, and public Firebase config risk.

## Current Product Understanding

For Rent is a rental property portfolio app where landlords create and manage listings, tenants browse and request properties, and guests can browse public listings before signing in for protected actions.

## Current Technical Architecture

- Xcode project: `For Rent.xcodeproj`
- Target: `For Rent`
- Entry point: `For Rent/ForRentApp.swift`
- Root routing: `For Rent/ContentView.swift`
- Models: `AppUser`, `Property`, `Request`, `RequestStatus`, `UserRole`
- ViewModels: `AuthViewModel`, `PropertyViewModel`, `RequestViewModel`, `ShortlistViewModel`
- Services: `AuthService`, `FirestoreService`, `UserDefaultsManager`, `ImageManager`
- UI: SwiftUI views under `Views/Auth`, `Views/Landlord`, `Views/Tenant`, `Views/Guest`, `Views/Shared`, and `Views/Components`
- Backend: Firebase Auth and Firestore via Swift Package Manager

## Current App Flow

Unauthenticated users land on `LoginView`, can create an account in `SignUpView`, or continue as guest. Authenticated users are routed by `AppUser.role` to `TenantTabView`, `LandlordTabView`, or `GuestHomeView`. Landlords manage listings and requests. Tenants browse listings, save properties, and send requests. Guests browse listings and can view details.

## What Works

- SwiftUI app target exists and resolves Firebase packages.
- Firebase Auth email/password is wired for sign up and login.
- Firestore user, property, request, and shortlist documents are modeled.
- Landlord add/update property flow exists.
- Tenant/guest property browsing exists.
- Tenant request creation exists.
- Landlord request accept/reject flow exists.
- Shortlist local persistence and Firestore sync are present.
- `xcodebuild` simulator build succeeds after upgrade.

## What Is Broken

- Before upgrade, auth state was not restored safely on launch.
- Some protected flows force-unwrapped `authVM.user`.
- Landlords saw all properties instead of only their own.
- Tenant/guest browse screens displayed unavailable and assigned listings.
- Delete action did not delete; it re-saved the same property then removed local state.
- Profile edits changed only local memory and were lost after relaunch.
- Request creation and status updates used `try?`, hiding Firestore failures.
- Request acceptance did not update property availability.
- `isListed` in `AddPropertyView` was ignored by `PropertyViewModel`.
- User-facing docs and copy used `For Rent`, not **For Rent**.

## What Is Incomplete

- Images are stored locally with `FileManager`, not Firebase Storage.
- Firestore security rules are not included in the repo.
- Search is basic title/description and max-rent filtering.
- No automated unit/UI test target is configured.
- No screenshot assets are present for README.
- Guest actions are browse/detail/share only.

## Wire-Up Issues

- `ForRentApp` initialized `AuthViewModel` before Firebase configuration; this was made safer by configuring Firebase before creating `StateObject` view models.
- `RequestViewModel` now keeps a single listener instead of creating repeated listeners on view refresh.
- `PropertyViewModel` now owns add/update/delete/de-list operations instead of views calling Firestore directly.
- `ShortlistView` now avoids force unwraps and loads tenant shortlist from Firestore.

## Firebase/Auth Issues

- Auth profile restoration was missing.
- Profile updates were not persisted.
- Login and sign-up validation was too light.
- A real `GoogleService-Info.plist` was detected locally under `For Rent/Services/`.

## Firestore CRUD Issues

- Property create/read/update existed.
- Property delete and de-list were incomplete.
- Request create/update existed but swallowed errors.
- Request acceptance did not update `Property.isAssigned` or `Property.isListed`.
- Shortlist updates existed but swallowed errors and did not rollback local state.

## Navigation Issues

- `RootView` duplicates `ContentView` routing and appears unused.
- Some views create nested `NavigationStack`s inside tab stacks.
- Tenant and saved flows force-unwrapped user state before upgrade.

## Role-Permission Issues

- Landlord property list was not scoped to the logged-in landlord.
- Protected tenant actions were visible to guests without a clear prompt.
- ViewModels did not consistently verify the current role before mutations.

## State-Management Issues

- Success states were mostly absent.
- Loading states existed in some screens but not across all mutations.
- Optimistic request/shortlist updates lacked rollback before upgrade.

## UX Issues

- Product name and tagline were inconsistent.
- Empty states were sparse.
- Search/filter UI was missing.
- Listing status and assigned status were not visible on property cards.
- Destructive property actions lacked confirmation.

## Accessibility Issues

- Some icon/text buttons lacked descriptive labels.
- Property cards were not combined into useful screen-reader summaries.
- Empty states used text only in several places.
- Dynamic Type is mostly supported by SwiftUI defaults, but custom card layout needs manual device checks.

## Security/Public Repo Issues

- `.gitignore` was missing.
- `GoogleService-Info.plist` must not be committed.
- No Firebase setup example existed before upgrade.
- No rules/index expectations were documented.

## Priority Roadmap

### P0

- Use `For Rent` for project, target, product, folder, and user-facing identity; use `ForRentApp` where Swift requires a code-safe symbol.
- Restore auth state safely after app launch.
- Fix landlord property filtering.
- Fix property delete/de-list.
- Fix request create/update error handling.
- Update accepted request to update property availability.
- Persist profile updates.
- Remove force unwraps in tenant/saved flows.
- Add `.gitignore` and Firebase example config.

### P1

- Improve validation, loading, error, success, and empty states.
- Add search/max-rent filtering.
- Add role guards in ViewModels.
- Improve property/request cards and status visibility.
- Document architecture, data model, and testing.

### P2

- Add Firebase Storage for cross-device images.
- Add automated tests.
- Add screenshots and richer previews.
- Keep MapKit compatibility guarded for iOS 18 through iOS 26+ APIs.
- Refactor duplicate navigation roots.
