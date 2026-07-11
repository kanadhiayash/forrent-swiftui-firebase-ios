# For Rent Ship Readiness Audit

## Decision

Status: **Portfolio ship-ready with documented limitations**

For Rent is ready to publish as a GitHub portfolio project after real simulator
screenshots are added. It is not App Store production-ready because it still
needs production Firebase deployment review, cloud image storage, analytics,
monitoring, privacy/legal review, and release operations.

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
- Swift unit tests cover demo validation, property filtering, role guards,
  duplicate request prevention, request acceptance, shortlist rollback, and
  deterministic reset.
- Firebase emulator tests validate user/property/request ownership boundaries
  and role-escalation denial.
- GitHub Actions runs simulator build, unit tests, UI smoke tests, Firebase
  emulator tests, secret scan, and demo fixture validation.

## Launch Gates Still Manual

- Run tenant, landlord, and guest flows in Xcode with real Firebase test accounts.
- Deploy Firebase resources only after owner approval and environment review.
- Add real simulator screenshots to the README.
- Confirm Firebase indexes if Firestore asks for composite indexes during real queries.

## Remaining Non-Blocking Risks

- Property images are stored locally, so they do not sync across devices.
- Automated tests cover the critical demo, rules, and smoke paths, but do not
  replace a full real-Firebase manual walkthrough.
- The app is portfolio-grade, not production-grade, until storage, analytics,
  privacy/legal review, monitoring, incident response, and release operations
  exist.

## Recommended Pre-Figma Notes

- Treat the current SwiftUI screens as the functional source of truth.
- Preserve the landlord, tenant, and guest journeys.
- Design states for loading, empty, error, pending, accepted, rejected, listed, de-listed, assigned, and unavailable.
- Include README screenshots only after the simulator capture checklist in
  `docs/09_DEMO_CAPTURE_PACK.md` is complete.
