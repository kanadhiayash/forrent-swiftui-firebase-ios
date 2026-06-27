# For Rent Testing and Verification

## Automated gates

The shared Xcode scheme includes:

- `For RentTests`: fixture decoding, environment selection, deterministic reset,
  legacy listing migration, and inquiry transition tests.
- `For RentUITests`: launches the app, selects the demo guest, and verifies the
  public marketplace appears.

Firebase emulator tests verify:

- Public read and unauthenticated write boundaries.
- Role escalation denial.
- Listing owner enforcement.
- Valid renter inquiry creation.
- Denial of direct inquiry status changes.
- Storage upload and delete ownership.
- Non-routable demo account data.

## Commands

```bash
npm ci
npm audit --audit-level=moderate
npm run validate:demo
npm run test:firebase
npm run scan:secrets

xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest" \
  -parallel-testing-enabled NO
```

CI also removes `DemoSeed.json` temporarily and builds the same target to prove
that deleting the fixture is sufficient for clean Firebase mode.

## Manual product QA

Review compact iPhone, iPhone 17 Pro, and iPad layouts in light and dark mode.
For each, check:

- Default and accessibility Dynamic Type sizes.
- VoiceOver labels and reading order.
- Reduce Motion behavior.
- Guest sign-in handoff preserving the selected listing.
- Renter save and inquiry states.
- Landlord create, edit, publish, pause, and inquiry decisions.
- Loading, empty, error, unavailable, and missing-media states.

Real release screenshots and Firebase-account walkthrough evidence must be
captured before a public release. No placeholder image should be represented as
release evidence.
