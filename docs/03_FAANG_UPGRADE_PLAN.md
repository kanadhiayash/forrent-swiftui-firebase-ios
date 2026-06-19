# For Rent FAANG Upgrade Plan

## Product Upgrade Goals

- Make **For Rent** a coherent role-based rental app prototype.
- Ensure each major landlord, tenant, and guest action has a clear state outcome.
- Keep limitations honest and visible for portfolio review.

## Engineering Upgrade Goals

- Preserve SwiftUI and MVVM.
- Move Firebase mutations behind services/view models.
- Avoid unsafe force unwraps.
- Add validation and role guards.
- Keep code beginner-readable.

## Firebase Upgrade Goals

- Restore auth profile on launch.
- Use typed Firestore models.
- Make request acceptance update both request and property availability.
- Add public repo safety around Firebase config.

## UX Upgrade Goals

- Rename user-facing product to **For Rent**.
- Add useful loading, empty, error, and success states.
- Add search and max-rent filtering.
- Make listing/availability status visible.

## Accessibility Upgrade Goals

- Use semantic controls.
- Add accessibility labels to high-value actions and cards.
- Avoid color-only status communication.
- Preserve Dynamic Type-friendly SwiftUI text.

## GitHub Readiness Goals

- Add `.gitignore`.
- Add Firebase example plist.
- Add recruiter-readable README.
- Add docs covering audit, data model, testing, and roadmap.
- Clearly document that real `GoogleService-Info.plist` must not be committed.

## Documentation Goals

- Create `docs/00_PROJECT_AUDIT.md` through `docs/07_FINAL_UPGRADE_SUMMARY.md`.
- Add root `README.md`.
- Keep documentation specific to actual files and known limitations.

## Ordered Implementation Plan

1. Audit structure, views, models, services, Firebase usage, and docs.
2. Rename user-facing product copy and app display name.
3. Fix auth state restoration and role persistence.
4. Fix property and request CRUD wiring.
5. Add role guards, validation, and safe optional handling.
6. Improve UX states and accessibility labels.
7. Add public repo safety files and Firebase docs.
8. Run Xcode build.
9. Document final state and next Git commands.

## P0 Fixes

- Auth listener and safe Firebase initialization order.
- Landlord-owned property filtering.
- Listed/unassigned browsing filter.
- Property delete and de-list.
- Request send/update error handling.
- Accepted request marks property assigned and unlisted.
- Profile update persists to Firestore.
- Firebase config gitignore/example.

## P1 Improvements

- Search/max-rent filter.
- Better empty/loading/error states.
- Success messages.
- Confirmation alert for delete.
- Status labels on property cards.
- README and docs.

## P2 Polish

- Accessibility labels and combined card summary.
- App display name **For Rent**.
- Future screenshots placeholder.
- MapKit coordinate selection guarded for iOS 18 and iOS 26+ compatibility.

## Risks

- No automated tests are configured.
- Real Firebase rules are not included.
- Local images do not sync across devices.
- Existing `GoogleService-Info.plist` is present locally and must be excluded from commits.
- Duplicate `RootView` remains as a legacy unused route.

## Testing Checklist

- `xcodebuild -list -project "For Rent.xcodeproj"`
- `xcodebuild -showdestinations -project "For Rent.xcodeproj" -scheme "For Rent"`
- `xcodebuild build -project "For Rent.xcodeproj" -scheme "For Rent" -destination 'generic/platform=iOS Simulator'`
- Manual tenant sign-up/login.
- Manual landlord sign-up/login.
- Manual add/update/delete/de-list property.
- Manual send/accept/deny request.
- Manual shortlist add/remove.

## Acceptance Criteria

- Clear product purpose.
- Clean SwiftUI MVVM architecture.
- Safe Firebase Authentication flow.
- Reliable Firestore CRUD operations for the prototype scope.
- Clear role-based access.
- Predictable state management.
- Stronger validation.
- Useful error/loading/empty states.
- Accessible UI improvements.
- Consistent naming.
- Professional README.
- No intentional public exposure of Firebase private config.
- Clean public GitHub structure.
