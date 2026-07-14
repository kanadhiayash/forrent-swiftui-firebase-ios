# Changelog

## Unreleased

### Added

- Approved Question Mark Home logo, app icon, and runtime brand assets.
- Semantic light and dark color tokens based on The Sign Palette.
- Validated profile draft state with focused unit coverage.
- Shared Account screen, identity header, account rows, and focused Personal Details editor.
- UI smoke coverage for guest browse, landlord profile edit/reset, invalid profile save, and unsaved-change discard protection.

### Changed

- Replaced the previous blue theme foundation with the approved For Rent identity.
- Updated global action tint and shared button states.
- Applied the approved logo to the authentication entry screen.
- Changed profile updates to return explicit results while preserving the signed-in user on persistence failure.
- Replaced legacy renter and landlord profile tabs with the shared Account experience.
- Changed profile saves to validate changed drafts on tap so inline errors explain blocking fields.
