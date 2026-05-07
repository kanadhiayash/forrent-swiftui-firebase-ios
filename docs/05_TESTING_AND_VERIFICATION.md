# For Rent Testing And Verification

## What Was Tested

- Project discovery with `xcodebuild -list`.
- Destination discovery with `xcodebuild -showdestinations`.
- Simulator build with `xcodebuild build`.
- Swift compile after Firebase/Auth/Firestore/view rewiring.

## Build Verification Status

Status: **Build succeeded**

Command:

```bash
xcodebuild build -project FourRent.xcodeproj -scheme FourRent -destination 'generic/platform=iOS Simulator'
```

Result:

```text
** BUILD SUCCEEDED **
```

Warnings:

- No project-specific Swift compile warnings were observed in the final command-line build. Xcode emitted an AppIntents metadata note because the app does not use AppIntents.

## Manual Xcode Verification Steps

1. Open `FourRent.xcodeproj`.
2. Add your local `GoogleService-Info.plist` under `FourRent/Services/`.
3. Select a simulator.
4. Run the app.
5. Test tenant, landlord, and guest paths with separate Firebase accounts.

## Auth Flow Checklist

- Sign up as tenant.
- Sign up as landlord.
- Login as tenant.
- Login as landlord.
- Logout.
- Relaunch app and confirm Firebase auth-state restoration.

## Landlord Flow Checklist

- Add a property with valid title, details, rent, bedroom, bathroom, location, and listing status.
- Confirm only owned properties appear in My Properties.
- Update property fields.
- De-list property and confirm it disappears from tenant/guest browsing.
- Delete property after confirmation.
- View incoming requests.
- Accept a pending request.
- Deny a pending request.

## Tenant Flow Checklist

- Browse available listed/unassigned rentals.
- Search by title/details.
- Filter by maximum rent.
- View property detail.
- Save a property.
- Remove saved property.
- Send one request to a property.
- Confirm duplicate request is blocked.
- View request status.

## Guest Flow Checklist

- Continue as guest.
- Browse available rentals.
- View property details.
- Share property.
- Try to save/request and confirm sign-in prompt appears.

## Firebase Checklist

- Email/password Auth enabled.
- Firestore enabled.
- Real `GoogleService-Info.plist` exists locally but is not committed.
- `firestore.rules` exists and should be deployed or emulator-tested before sharing a Firebase backend.

## Firestore Checklist

- `users/{uid}` created at sign-up.
- `properties/{propertyId}` created/updated/deleted by landlord.
- `requests/{requestId}` created by tenant.
- Accepted request updates request status and property availability.
- `users/{uid}.shortlisted` updates on save/remove.
- Tenant/guest property reads use listed/unassigned queries.
- Landlord property reads use landlord-owned queries.
- Request listeners are scoped by tenant or landlord ID.

## Accessibility Checklist

- Property cards expose a combined accessibility summary.
- Login button has descriptive label.
- Search and rent filters have accessibility labels.
- Status uses icon plus text, not color alone.
- Empty states use clear copy.

## Known Limitations

- No automated test target.
- No Firebase Storage; listing images are local to the device.
- Firestore security rules are included but not emulator-tested.
- No README screenshots yet.
- Manual simulator walkthrough is still required for full Firebase account and Firestore rule validation.

## Remaining Risks

- Manual Firebase rules can still allow incorrect access if misconfigured.
- Local image filenames in Firestore do not work across devices.
- Real Firebase plist must be kept out of Git history.
