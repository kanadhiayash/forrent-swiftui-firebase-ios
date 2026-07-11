# For Rent Demo Capture Pack

## Capture Positioning

For Rent should be presented as a portfolio-grade SwiftUI Firebase prototype.
Do not describe it as production-ready, App Store-released, deployed, or backed
by live operational monitoring unless that work is completed and verified later.

Use only real simulator screenshots or recordings captured from the current app.
Do not use generated mockups, placeholder images, or fixture screenshots as proof
of shipped behavior.

## Demo Mode

`For Rent/Resources/DemoSeed.json` is the deterministic demo switch.

- Keep the fixture present for portfolio walkthroughs.
- Delete or temporarily move the fixture only when proving clean Firebase mode.
- Demo records mutate in memory and reset on relaunch or through Reset Demo.
- Demo account data is non-routable and must not be described as real users.

Clean Firebase mode proof:

```bash
mv "For Rent/Resources/DemoSeed.json" /tmp/DemoSeed.json
xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination "generic/platform=iOS Simulator" \
  CODE_SIGNING_ALLOWED=NO
mv /tmp/DemoSeed.json "For Rent/Resources/DemoSeed.json"
```

## Required Pre-Capture Gates

Run these before recording or screenshot capture:

```bash
npm ci
npm run validate:demo
npm run test:firebase
npm run scan:secrets

xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro,OS=latest" \
  -parallel-testing-enabled NO
```

Also confirm `GoogleService-Info.plist` is local-only:

```bash
git check-ignore -v GoogleService-Info.plist
```

## Manual QA Script

### Guest

1. Launch the app with `DemoSeed.json` present.
2. Choose Browse as guest.
3. Search or filter listings.
4. Open a listing detail page.
5. Confirm category, location, pricing cadence, amenities, availability, and
   missing-image states read cleanly.
6. Try a protected action and confirm the app preserves the selected listing
   context while asking for sign-in.

### Renter

1. Select the renter demo account.
2. Browse listings and save a property.
3. Open the saved property and submit an inquiry.
4. Confirm duplicate inquiries are blocked.
5. Confirm pending, accepted, rejected, or cancelled states appear in the
   listing detail and inquiry surfaces.

### Landlord

1. Select the landlord demo account.
2. Review owned listings.
3. Create or edit a listing with validation errors first, then valid data.
4. Publish and pause a listing.
5. Accept and reject inquiries.
6. Confirm accepted inquiries make the property unavailable or assigned in the
   relevant surfaces.

### Accessibility and Layout

Check compact iPhone, iPhone 17 Pro, and iPad where practical.

- Light and dark mode.
- Default and accessibility Dynamic Type.
- VoiceOver labels and reading order.
- Reduce Motion.
- Loading, empty, error, unavailable, and missing-media states.

## Screenshot Checklist

Capture real screenshots for these states:

- Guest marketplace browse.
- Listing detail with rich property facts.
- Listing detail with missing-image fallback.
- Protected guest action handoff.
- Renter saved listings.
- Renter inquiry submitted state.
- Landlord listing management.
- Landlord inquiry review.
- Empty or unavailable state.

Recommended public asset paths, once real media exists:

- `docs/assets/screenshots/guest-marketplace.png`
- `docs/assets/screenshots/listing-detail.png`
- `docs/assets/screenshots/renter-inquiry.png`
- `docs/assets/screenshots/landlord-review.png`

Leave the README screenshot section out or clearly marked as pending until these
files exist and are captured from the current app.

## Demo Recording Outline

1. Start from the account chooser.
2. Show guest browsing and a protected action.
3. Switch to renter, save a listing, and submit an inquiry.
4. Switch to landlord, review the inquiry, and accept it.
5. Return to the listing detail to show the changed availability state.

Keep the recording short and truthful. Do not add fake metrics, fake App Store
badges, fake production claims, or fake deployment links.
