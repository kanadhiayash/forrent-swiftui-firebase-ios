# For Rent Project Brief

## Project Name

For Rent

## Product Category

iOS rental property app / portfolio prototype.

## One-Line Description

For Rent helps landlords and renters manage rental discovery, property listings, saved homes, and rental requests through clear role-based SwiftUI flows.

## Target Users

- Landlords listing and managing rental properties.
- Tenants browsing rentals and sending requests.
- Guests browsing public listings before account creation.

## Primary Problem

Rental workflows span listing creation, discovery, saved properties, requests, approvals, availability, and role-specific access. Without strong state and data wiring, the experience becomes confusing and unreliable.

## Secondary Problems

- Users need clear loading, empty, error, and success feedback.
- Landlords must not manage other landlords' listings.
- Guests need obvious prompts before protected actions.
- Portfolio reviewers need to understand Firebase setup without private credentials.

## Product Solution

For Rent provides a role-based SwiftUI experience backed by Firebase Auth and Firestore where landlords manage listings and requests, tenants browse/save/request properties, and guests browse available listings.

## Landlord Journey

1. Create a landlord account or log in.
2. View only owned properties.
3. Add property details, rent, location, listing status, and images.
4. Update, de-list, or delete owned listings.
5. View incoming requests.
6. Accept or deny tenant requests.
7. Accepted requests mark the property assigned and remove it from public browsing.

## Tenant Journey

1. Create a tenant account or log in.
2. Browse listed and unassigned properties.
3. Search listings and optionally filter by max rent.
4. View property details.
5. Save/remove properties.
6. Send one request per property.
7. Track pending, accepted, or rejected request status.

## Guest Journey

1. Continue as guest.
2. Browse listed and unassigned properties.
3. View property details and share a property.
4. Sign in when trying to save or request a property.

## Core Features

- Email/password auth.
- Role selection and role-based routing.
- Landlord property CRUD.
- Tenant/guest property browsing.
- Search and max-rent filter.
- Shortlist/favorites.
- Rental request creation.
- Landlord approval/denial.
- Profile display and profile update.
- Loading, error, empty, and confirmation states.

## Non-Goals

- Real payment processing.
- Lease signing.
- Messaging/chat.
- Production-grade identity verification.
- Production-ready security rules in this prototype repo.
- Cross-device image storage until Firebase Storage is added.

## Technical Stack

- SwiftUI
- MVVM with ObservableObject view models
- Firebase Authentication
- Cloud Firestore
- MapKit
- PhotosUI
- Local `FileManager` image persistence
- UserDefaults for local shortlist cache

## Architecture Direction

Keep views presentation-focused, view models responsible for state and validation, and service classes responsible for Firebase operations. Use **For Rent** consistently for project and product identity, with `ForRentApp` only where Swift requires a code-safe symbol.

## Firebase/Auth Strategy

Use Firebase Authentication email/password for tenant and landlord accounts. Store role and profile metadata in `users/{uid}`. Guest sessions are local-only and do not create Firebase users.

## Firestore Data Strategy

Use top-level collections: `users`, `properties`, and `requests`. Store stable document IDs in model `id` fields. Keep shortlist IDs on the user document for the prototype.

## UX Principles

- Each role should have one obvious next action.
- State should be visible: loading, empty, error, success, listed, de-listed, assigned.
- Protected actions should explain why sign-in is needed.
- Keep copy honest and direct.

## Accessibility Principles

- Use semantic SwiftUI controls.
- Add descriptive accessibility labels for cards and protected actions.
- Use text and icons together for status.
- Respect Dynamic Type where practical.
- Avoid color-only status meaning.

## Security/Privacy Principles

- Do not commit real Firebase config, private keys, or service accounts.
- Document required Firebase setup with an example plist.
- Role checks must exist in the app and should be enforced again in Firestore rules.
- Do not overclaim production readiness.

## Portfolio Positioning Statement

For Rent is a portfolio-grade iOS rental app prototype demonstrating SwiftUI, MVVM, Firebase Authentication, Firestore CRUD, role-based navigation, and practical UX state handling.

## Success Criteria

- App builds from Xcode.
- Public-facing name is **For Rent**.
- Tenant, landlord, and guest flows are logically connected.
- Firestore operations use typed models and visible error handling.
- README and docs explain setup and limitations.

## Future Roadmap

- Firebase Storage for listing photos.
- Firestore security rules and emulator tests.
- Unit tests for view models.
- UI tests for role flows.
- Screenshot-driven README.
- Firebase Storage-backed listing images.
