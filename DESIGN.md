# For Rent Design System

## Direction

For Rent is a restrained, high-trust iOS product. Use Apple-native interaction patterns, clear hierarchy, generous but efficient spacing, and strong state communication. The visual quality target is a premium rental marketplace, not an Airbnb replica.

## Color

### Core

- Trust blue `primary`: `#003580`
- Trust blue active `primaryActive`: `#00224F`
- Action blue `action`: `#0071C2`
- Action blue active `actionActive`: `#005999`
- Highlight yellow `yellow`: `#FFB700`, always with dark text
- `ink`: `#1A1A1A`
- `body`: `#474747`
- `muted`: `#6B6B6B`
- `canvas`: `#FFFFFF`
- `surfaceSoft`: `#F8FAFC`
- `surfaceStrong`: `#E0E2E6`
- `hairline`: `#DDDDDD`
- `borderStrong`: `#9297A0`

### Semantic

- Brand surfaces use trust blue. Primary task buttons use action blue.
- Destructive emphasis uses semantic red with a text label or icon.
- Confirmed and available states use semantic green with text or icon.
- Pending states use highlight yellow with dark text.
- Informational links use action blue.
- Color never carries status by itself.

## Typography

- Use the San Francisco system family through SwiftUI semantic text styles.
- Use `.largeTitle` only for true screen-level moments.
- Use `.title2` or `.title3` for primary screen headings.
- Use `.headline` for listing and section titles.
- Use `.body` for descriptions and form copy.
- Use `.subheadline` and `.caption` for metadata and supporting state.
- Support Dynamic Type; do not use fixed custom font sizes for core content.

## Spacing And Shape

- Base spacing unit: 4 points.
- Common gaps: 8, 12, 16, 24, and 32 points.
- Screen horizontal padding: 16 points compact, 24 points regular.
- Component corner radius: 8 points for controls and cards; 12 points only for large media.
- Minimum interactive target: 44 by 44 points.
- Use one-pixel hairlines or clear surface changes for grouping.
- Avoid cards inside cards and avoid floating page-section containers.

## Components

### Buttons

- Primary: full-width only when the task has one dominant completion action.
- Secondary: bordered or plain depending on hierarchy.
- Destructive: role-based SwiftUI button with coral text or fill.
- All buttons require disabled and loading states when an async action is possible.

### Listing Cards

- Lead with inspectable property imagery.
- Show title, human-readable location, monthly or nightly price, rental category, capacity facts, and availability.
- Saved state uses a familiar heart icon with an accessibility label.
- Do not show latitude/longitude to users.

### Status

- Every status uses text plus an icon or shape.
- Pending, confirmed, rejected, unavailable, listed, and draft states share one status-chip vocabulary.
- Toasts acknowledge lightweight completion; alerts are reserved for blocking or destructive decisions.

### Forms

- Group listing forms by basics, rental type, pricing, availability, location, media, and publishing.
- Use multiline text editors for descriptions.
- Validate near the field and summarize blocking errors before submission.
- Preserve entered data after recoverable failures.

### Navigation

- One `NavigationStack` owner per tab.
- Tabs reflect durable role workflows, not every feature.
- Sheets own their dismissal and completion actions.
- Protected guest actions explain the sign-in requirement without losing browsing context.

## Motion

- Use 100-250 ms state transitions.
- Prefer opacity and small positional transitions for state changes.
- Respect Reduce Motion.
- Do not animate screen content only for decoration.

## Imagery

- Portfolio seed data should include clear, well-lit, inspectable property imagery.
- Use consistent aspect ratios and avoid dark overlays that hide listing details.
- Placeholder states should preserve layout and identify missing media without looking broken.
