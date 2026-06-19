# For Rent Ship Readiness Audit

## Decision

Status: **Portfolio ship-ready with documented limitations**

For Rent is ready to publish as a GitHub portfolio project after screenshots are added. It is not yet App Store production-ready because it still needs automated tests, Firebase emulator rule validation, and cloud image storage.

## Launch Gates Passed

- Command-line Xcode simulator build succeeds.
- User-facing product name is **For Rent**.
- Project, target, product, source folder, and display name use `For Rent`; the Swift entry point uses `ForRentApp`.
- Firebase Auth and Firestore service boundaries are clear.
- Tenant/guest property browsing uses listed and unassigned property queries.
- Landlord property inventory uses owner-scoped queries.
- Request listeners are scoped by tenant or landlord ID.
- Duplicate rental requests are blocked with deterministic request document IDs.
- Request approval updates request status and property availability in one Firestore batch.
- Private Firebase config is ignored by Git.
- Public Firebase setup and data model docs are present.
- A baseline `firestore.rules` file is included.

## Launch Gates Still Manual

- Run tenant, landlord, and guest flows in Xcode with real Firebase test accounts.
- Deploy or emulator-test `firestore.rules`.
- Add screenshots to the README.
- Confirm Firebase indexes if Firestore asks for composite indexes during real queries.

## Remaining Non-Blocking Risks

- Property images are stored locally, so they do not sync across devices.
- There is no automated unit or UI test target yet.
- Firestore rules are included but have not been validated with the Firebase emulator.
- The app is portfolio-grade, not production-grade, until storage, tests, analytics, and operational monitoring exist.

## Recommended Pre-Figma Notes

- Treat the current SwiftUI screens as the functional source of truth.
- Preserve the landlord, tenant, and guest journeys.
- Design states for loading, empty, error, pending, accepted, rejected, listed, de-listed, assigned, and unavailable.
- Include README screenshots after the Figma pass or simulator polish pass.
