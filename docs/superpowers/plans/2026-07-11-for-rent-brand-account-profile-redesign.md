# For Rent Brand Foundation and Account Profile Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:subagent-driven-development` or `superpowers:executing-plans` to execute this plan task by task. Use an isolated Git worktree for each pull request. Track every checkbox. Stop on failed gates. Do not merge or publish without Yash Kanadhia's explicit approval.

**Goal:** Integrate the approved Question Mark Home identity and The Sign Palette into the For Rent iOS app, rebuild the semantic theme and token foundation, then replace the weak Profile and Edit Profile flow with a clear, safe, accessible Account and Personal Details experience.

**Architecture:** Treat the external brand package as the source for identity assets, but import only runtime assets and a small set of public brand source files into the repository. Separate exact brand primitives from semantic UI tokens. Preserve the current app-level environment and Firebase/demo boundaries. Add a feature-local profile editor model for draft, validation, dirty state, and submission state, while keeping persistence inside `AuthViewModel` and existing services.

**Tech stack:** SwiftUI, Swift, Observation or the repository's compatible observation pattern, Xcode asset catalogs, XCTest, XCUITest, Firebase Auth and Firestore, deterministic demo mode.

## Global constraints

- Repository: `kanadhiayash/forrent-swiftui-firebase-ios`
- Integration branch: `dev`
- Feature branches must be created from `dev`.
- Pull requests must target `dev`.
- Do not commit directly to `main`.
- Approved brand concept: `The Question Mark Home`.
- Approved palette: `The Sign Palette`.
- Approved brand colors:
  - Navy `#0A1A3A`
  - Royal Blue `#2563EB`
  - Teal `#10B981`
  - Light Gray `#F2F4F7`
  - White `#FFFFFF`
- Asset source directory:
  - `/Users/yashkanadhia/Documents/Dev-Projects/IOS/ForRent_QuestionMarkHome_BrandAssets_v1.0`
- Preserve exact brand geometry. Do not redraw, simplify, recolor, crop, trace, or regenerate the approved mark during implementation.
- Keep the iOS deployment target at `18.0` unless a separate migration is explicitly approved.
- Keep the current Swift language mode unchanged during this work.
- Do not add third-party UI, validation, phone-formatting, or snapshot-test dependencies.
- Do not add profile photo upload, password change, email editing, role editing, verification badges, ratings, or landlord analytics.
- Keep email and role read-only.
- Use an initials avatar. Do not add a fake user photo.
- The demo email remains secondary metadata and must be visibly identified as demo data.
- Do not print or commit real Firebase credentials.
- `For Rent/Services/GoogleService-Info.plist` must remain ignored.
- Do not copy the full 206-file brand package into the app repository.
- Do not overwrite the root `Contents.json` of the existing Xcode asset catalog.
- Do not create a second asset named `AppIcon`.
- Do not claim App Store release, production deployment, or verified commercial trademark clearance.
- No screenshot may be added until captured from the implemented current build.
- Use native SwiftUI navigation, lists, forms, confirmation dialogs, toolbars, accessibility, and Dynamic Type behavior.
- Use semantic colors in screens and components. Do not place hex values in feature views.
- Use SF Symbols for interface actions. Use the approved brand symbol only for brand identity.
- Every PR must build and pass its relevant tests independently.
- Every commit must contain one coherent change and use Conventional Commit style.

---

# 1. Verified repository baseline

Codex must re-check these facts locally before editing:

1. `For Rent/DesignSystem/ForRentDesignTokens.swift` currently contains the old trust-blue palette and programmatic light/dark colors.
2. `For Rent/Views/Components/ButtonStyles.swift` depends on the current theme names and does not respect Reduce Motion.
3. `For Rent/Views/Auth/LoginView.swift` currently uses a system building icon instead of the approved brand asset.
4. `For Rent/Views/Landlord/LandlordTabView.swift` overrides the global tint with `.tint(.black)`.
5. `For Rent/Views/Shared/ProfileView.swift` is a simple vertical stack with direct Reset Demo and Logout actions.
6. `For Rent/Views/Shared/EditProfileView.swift` owns three raw text fields and a single Update Profile button.
7. `AuthViewModel.updateProfile` updates demo or Firebase data but communicates completion through shared global strings rather than a typed editor state.
8. The app target is configured to use `AppIcon`.
9. The application source root `For Rent` is file-system synchronized. New app source files inside it should be included automatically.
10. The test groups are not file-system synchronized. New unit test files require target membership updates in `For Rent.xcodeproj/project.pbxproj`.
11. `DemoSession.reset()` restores personas, properties, requests, and shortlisted IDs from the seed while preserving the selected demo-user ID.
12. `AppUser` currently contains `id`, `email`, `role`, `firstName`, `lastName`, `phone`, and `shortlisted`.

## Baseline commands

Run from the repository clone that Codex will modify:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
ASSET_SOURCE="/Users/yashkanadhia/Documents/Dev-Projects/IOS/ForRent_QuestionMarkHome_BrandAssets_v1.0"

cd "$REPO_ROOT"

git status --short --branch
git remote -v
git fetch origin --prune
git switch dev
git pull --ff-only origin dev

test -f "$REPO_ROOT/AGENTS.md"
test -d "$ASSET_SOURCE"
test -f "$ASSET_SOURCE/SHA256SUMS.txt"
test -d "$ASSET_SOURCE/04_XCODE_READY/ForRentBrand.xcassets"
test -f "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Default-1024.png"

git status --short --branch
```

Expected state:

- Current branch is `dev`.
- `dev` matches `origin/dev`.
- The working tree is clean.
- The brand package checks pass.
- No real credential content is printed.

If the working tree is not clean, stop. Preserve or commit existing user work before continuing.

---

# 2. Facts, assumptions, unknowns, and risks

## Facts

- Question Mark Home is approved.
- The Sign Palette is approved.
- The asset package has Xcode-ready imagesets, colorsets, app-icon exports, vector masters, brand tokens, and a guide.
- The current app has a central `ForRentTheme`.
- The current app already supports demo and Firebase profile updates.
- The current app already has centralized success feedback through `FeedbackCenter`.
- The current navigation gives each tab its own `NavigationStack`.

## Assumptions to verify

- The local repository clone is open at a path separate from the asset source directory.
- The app has one existing `Assets.xcassets` catalog under `For Rent`.
- The existing app-icon schema may or may not expose default, dark, and tinted appearance slots.
- No other screen depends on profile editing copy or navigation behavior.
- No other target or extension uses a different app-icon asset name.

## Unknowns that must be resolved during preflight

- Exact local path of the app repository.
- Exact path of the existing `Assets.xcassets`.
- Existing app-icon `Contents.json` schema.
- Whether any uncommitted user assets already exist inside the catalog.
- Whether the current Xcode installation exposes current dark and tinted app-icon appearance slots in this project.
- Whether profile editing has hidden UI-test dependencies outside the current smoke test.

## Main risks

1. Duplicate `AppIcon` assets can break asset compilation.
2. Copying the full package into the app target can bloat the application bundle.
3. Changing old token names without compatibility aliases can cause broad build failures.
4. Updating colors without checking disabled and destructive states can create contrast failures.
5. A cosmetic profile redesign without typed state can preserve the current functional defects.
6. Moving profile persistence into a new layer can accidentally bypass demo or Firebase behavior.
7. Shared `AuthViewModel.successMessage` can trigger stale or unrelated success toasts.
8. Unsaved-change protection can break native back navigation if implemented with parallel flags.
9. Adding new test files without target membership can produce false confidence because tests will not run.
10. Updating all screens in one PR will make review and rollback too difficult.

---

# 3. Locked product decisions

These decisions are part of the execution scope:

1. Rename the shared `Profile` tab to `Account` for both tenant and landlord roles.
2. Rename the editing destination from `Edit Profile` to `Personal Details`.
3. Keep `email` and `role` read-only.
4. Use an initials avatar.
5. Show a `Demo` badge only in demo mode.
6. Place identity first, followed by Personal Information, Account, Demo, and Session sections.
7. Place Reset Demo inside a demo-only section with explanation and confirmation.
8. Place Sign Out in its own session section with confirmation.
9. Use a navigation destination for Personal Details.
10. Hide the tab bar while editing Personal Details.
11. Use a trailing Save toolbar action.
12. Save is disabled until the draft is changed, valid, and not already saving.
13. Preserve entered values after recoverable failures.
14. Ask before discarding unsaved changes.
15. On successful save, update shared user state, show success feedback, and return to Account.
16. Use the approved Royal Blue as primary action and active tint.
17. Use Navy for primary text and high-trust dark surfaces.
18. Use Teal for availability and success, not as the main brand action.
19. Keep native SF typography through semantic SwiftUI text styles.
20. Do not use custom fonts in this work.

---

# 4. Pull request graph

Execute these PRs sequentially. Do not begin a dependent PR until its parent has been merged into `dev`.

## PR 1

**Branch**

```text
feat/for-rent__question-mark-brand-foundation
```

**Title**

```text
feat(brand): integrate Question Mark Home identity
```

**Purpose**

Import runtime brand assets, replace the app icon, rebuild brand and semantic tokens, remove conflicting tint overrides, update shared button behavior, and apply the approved lockup to the authentication entry screen.

## PR 2

**Branch**

```text
refactor/for-rent__profile-editor-state
```

**Title**

```text
refactor(profile): harden profile editing state
```

**Purpose**

Introduce a testable profile draft and editor state, convert profile update persistence into an explicit throwing result, preserve demo and Firebase behavior, and remove reliance on a shared success string for profile-save completion.

## PR 3

**Branch**

```text
feat/for-rent__account-personal-details
```

**Title**

```text
feat(account): redesign account and personal details
```

**Purpose**

Replace the old Profile and Edit Profile screens, rename the tabs, add confirmations, apply the new brand system, add accessibility and UI coverage, and update documentation and capture instructions.

## Final integration review

After all three PRs are merged into `dev` and verified, open one owner-reviewed `dev` to `main` pull request. Do not merge it automatically.

---

# 5. Target file map

## PR 1 files

### Read before editing

- `AGENTS.md`
- `DESIGN.md`
- `README.md`
- `For Rent.xcodeproj/project.pbxproj`
- `For Rent/DesignSystem/ForRentDesignTokens.swift`
- `For Rent/Views/Components/ButtonStyles.swift`
- `For Rent/ContentView.swift`
- `For Rent/Views/Auth/LoginView.swift`
- `For Rent/Views/Landlord/LandlordTabView.swift`
- Existing asset catalog `Contents.json`
- Existing `AppIcon.appiconset/Contents.json`
- `$ASSET_SOURCE/README.md`
- `$ASSET_SOURCE/SHA256SUMS.txt`
- `$ASSET_SOURCE/04_XCODE_READY/ForRentBrand.xcassets/Contents.json`
- `$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/README.md`

### Create

- `For Rent/DesignSystem/ForRentBrandAsset.swift`
- Semantic colorsets inside the existing `Assets.xcassets`
- `For Rent/Views/Components/BrandLockupView.swift`
- `For RentTests/ForRentThemeTests.swift`
- `docs/brand/README.md`
- `docs/brand/ForRent_QuestionMarkHome_BrandGuide_v1.0.pdf`
- `docs/brand/source/for-rent-symbol-primary.svg`
- `docs/brand/source/for-rent-one-line-horizontal-primary-no-tagline-outlined.svg`
- `docs/brand/tokens/for-rent-brand-tokens.json`
- `docs/superpowers/plans/2026-07-11-for-rent-brand-account-profile-redesign.md`

### Modify

- Existing `Assets.xcassets`
- Existing `AppIcon.appiconset`
- Existing `AccentColor.colorset`
- `For Rent/DesignSystem/ForRentDesignTokens.swift`
- `For Rent/Views/Components/ButtonStyles.swift`
- `For Rent/ContentView.swift`
- `For Rent/Views/Auth/LoginView.swift`
- `For Rent/Views/Landlord/LandlordTabView.swift`
- `For Rent.xcodeproj/project.pbxproj`
- `DESIGN.md`
- `CHANGELOG.md`

## PR 2 files

### Create

- `For Rent/ViewModels/ProfileEditor.swift`
- `For RentTests/ProfileEditorTests.swift`

### Modify

- `For Rent/ViewModels/AuthViewModel.swift`
- `For Rent/Services/AppEnvironment.swift` only if a narrow test seam is required
- `For Rent.xcodeproj/project.pbxproj`
- `CHANGELOG.md`

## PR 3 files

### Create

- `For Rent/Views/Shared/AccountView.swift`
- `For Rent/Views/Shared/PersonalDetailsView.swift`
- `For Rent/Views/Components/AccountIdentityHeader.swift`
- `For Rent/Views/Components/AccountRow.swift`
- `For Rent/Models/AppUser+Display.swift`
- `docs/10_ACCOUNT_PROFILE_REDESIGN.md`

### Delete after replacement compiles

- `For Rent/Views/Shared/ProfileView.swift`
- `For Rent/Views/Shared/EditProfileView.swift`

### Modify

- `For Rent/Views/Landlord/LandlordTabView.swift`
- `For Rent/Views/Tenant/TenantTabView.swift`
- `For Rent/ViewModels/AuthViewModel.swift` only for reset/sign-out copy or a narrow action result
- `For RentUITests/ForRentSmokeTests.swift`
- `DESIGN.md`
- `docs/09_DEMO_CAPTURE_PACK.md`
- `CHANGELOG.md`

---

# PR 1: Brand foundation

## Task 1: Create the worktree and capture baseline evidence

- [ ] Create the worktree.

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_ROOT="$(dirname "$REPO_ROOT")/.worktrees"
BRANCH="feat/for-rent__question-mark-brand-foundation"
WORKTREE="$WORKTREE_ROOT/for-rent-question-mark-brand-foundation"

mkdir -p "$WORKTREE_ROOT"
git -C "$REPO_ROOT" fetch origin --prune
git -C "$REPO_ROOT" worktree add "$WORKTREE" -b "$BRANCH" origin/dev
cd "$WORKTREE"
```

- [ ] Save the baseline.

```bash
mkdir -p .codex/evidence/brand-foundation

git status --short --branch | tee .codex/evidence/brand-foundation/00-git-status.txt
xcodebuild -version | tee .codex/evidence/brand-foundation/01-xcode-version.txt
xcodebuild -list -project "For Rent.xcodeproj" \
  | tee .codex/evidence/brand-foundation/02-xcode-list.txt

xcodebuild -showBuildSettings \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  | grep -E "IPHONEOS_DEPLOYMENT_TARGET|SWIFT_VERSION|ASSETCATALOG_COMPILER_APPICON_NAME|ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME" \
  | tee .codex/evidence/brand-foundation/03-build-settings.txt
```

Expected:

- Deployment target remains `18.0`.
- App icon asset name remains `AppIcon`.
- Accent color asset name remains `AccentColor`.
- No source edits exist yet.

- [ ] Run the baseline build before touching assets.

```bash
xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  | tee .codex/evidence/brand-foundation/04-baseline-build.txt
```

Expected: `** BUILD SUCCEEDED **`.

If the baseline fails, stop and report the sanitized failure. Do not mix baseline repair into the brand PR without owner approval.

---

## Task 2: Verify the external asset package

- [ ] Verify package checksums without modifying files.

```bash
ASSET_SOURCE="/Users/yashkanadhia/Documents/Dev-Projects/IOS/ForRent_QuestionMarkHome_BrandAssets_v1.0"

cd "$ASSET_SOURCE"
shasum -a 256 -c SHA256SUMS.txt \
  | tee "$WORKTREE/.codex/evidence/brand-foundation/05-brand-checksums.txt"
```

Expected: every listed asset reports `OK`.

- [ ] Verify required files.

```bash
required_assets=(
  "04_XCODE_READY/ForRentBrand.xcassets/AppIcon.appiconset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandSymbol.imageset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandLogoHorizontal.imageset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandNavy.colorset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandRoyalBlue.colorset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandTeal.colorset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandLightGray.colorset/Contents.json"
  "04_XCODE_READY/ForRentBrand.xcassets/BrandWhite.colorset/Contents.json"
  "03_IOS_APP_ICON/Masters_1024/AppIcon-Default-1024.png"
  "03_IOS_APP_ICON/Masters_1024/AppIcon-Dark-1024.png"
  "03_IOS_APP_ICON/Masters_1024/AppIcon-Tinted-Monochrome-1024.png"
  "07_BRAND_GUIDE/ForRent_QuestionMarkHome_BrandGuide_v1.0.pdf"
  "01_MASTER_VECTOR/Symbol/for-rent-symbol-primary.svg"
  "01_MASTER_VECTOR/Lockups/for-rent-one-line-horizontal-primary-no-tagline-outlined.svg"
  "06_BRAND_TOKENS/for-rent-brand-tokens.json"
)

for relative_path in "${required_assets[@]}"; do
  test -f "$ASSET_SOURCE/$relative_path" || {
    printf 'Missing required asset: %s\n' "$relative_path"
    exit 1
  }
done
```

- [ ] Verify app-icon master properties.

```bash
sips -g pixelWidth -g pixelHeight -g format -g hasAlpha \
  "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Default-1024.png" \
  "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Dark-1024.png" \
  "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Tinted-Monochrome-1024.png" \
  | tee "$WORKTREE/.codex/evidence/brand-foundation/06-app-icon-properties.txt"
```

Required:

- Every master is `1024 x 1024`.
- Production app-icon artwork has no alpha.
- Files decode without warnings.

---

## Task 3: Locate and preserve the existing asset catalog

- [ ] Resolve the current catalog and app-icon paths.

```bash
cd "$WORKTREE"

ASSET_CATALOG="$(find "$WORKTREE/For Rent" -type d -name 'Assets.xcassets' -print -quit)"
test -n "$ASSET_CATALOG"
test -d "$ASSET_CATALOG"

CURRENT_APPICON="$ASSET_CATALOG/AppIcon.appiconset"
CURRENT_ACCENT="$ASSET_CATALOG/AccentColor.colorset"

test -d "$CURRENT_APPICON"
test -f "$CURRENT_APPICON/Contents.json"
test -d "$CURRENT_ACCENT"
test -f "$CURRENT_ACCENT/Contents.json"

printf 'ASSET_CATALOG=%s\n' "$ASSET_CATALOG" \
  | tee .codex/evidence/brand-foundation/07-asset-catalog-path.txt
```

- [ ] Preserve the current assets in ignored user-work storage.

```bash
STAMP="$(date +%Y%m%d-%H%M%S)"
PRESERVE_DIR="$WORKTREE/.codex/preserved-user-work/$STAMP/brand-assets"

mkdir -p "$PRESERVE_DIR"
ditto "$CURRENT_APPICON" "$PRESERVE_DIR/AppIcon.appiconset"
ditto "$CURRENT_ACCENT" "$PRESERVE_DIR/AccentColor.colorset"

find "$PRESERVE_DIR" -type f -print \
  | sort \
  | tee .codex/evidence/brand-foundation/08-preserved-assets.txt
```

Do not stage `.codex/preserved-user-work`.

- [ ] Inspect current and packaged icon schemas.

```bash
plutil -p "$CURRENT_APPICON/Contents.json" \
  | tee .codex/evidence/brand-foundation/09-current-appicon-schema.txt

plutil -p "$ASSET_SOURCE/04_XCODE_READY/ForRentBrand.xcassets/AppIcon.appiconset/Contents.json" \
  | tee .codex/evidence/brand-foundation/10-package-appicon-schema.txt
```

Decision rule:

1. If the current schema already contains default, dark, or tinted appearance entries, preserve that schema and replace only the image files referenced by each appearance.
2. If the current schema is a traditional size-slot catalog, replace the catalog with the packaged `AppIcon.appiconset`.
3. Do not invent `Contents.json` appearance keys from memory.
4. If Xcode exposes dark and tinted slots but the checked-in schema does not, use Xcode to create the appearance slots, then map:
   - Default: `AppIcon-Default-1024.png`
   - Dark: `AppIcon-Dark-1024.png`
   - Tinted: `AppIcon-Tinted-Monochrome-1024.png`
5. If the installed Xcode does not expose those slots for this target, ship the approved default icon and copy the dark and tinted masters to `docs/brand/app-icon-masters/`. Record the limitation. Do not fake support.

---

## Task 4: Merge runtime identity assets into the existing catalog

- [ ] Copy only the approved runtime sets. Do not copy the package catalog root.

```bash
PACKAGE_CATALOG="$ASSET_SOURCE/04_XCODE_READY/ForRentBrand.xcassets"

for asset_set in \
  BrandSymbol.imageset \
  BrandLogoHorizontal.imageset \
  BrandNavy.colorset \
  BrandRoyalBlue.colorset \
  BrandTeal.colorset \
  BrandLightGray.colorset \
  BrandWhite.colorset
do
  rm -rf "$ASSET_CATALOG/$asset_set"
  ditto "$PACKAGE_CATALOG/$asset_set" "$ASSET_CATALOG/$asset_set"
done
```

- [ ] Replace or map the app icon according to the schema decision in Task 3.

For a traditional catalog:

```bash
rm -rf "$CURRENT_APPICON"
ditto "$PACKAGE_CATALOG/AppIcon.appiconset" "$CURRENT_APPICON"
```

For an appearance-aware catalog:

- Preserve the existing `Contents.json`.
- Copy the approved 1024 masters into the filenames referenced by the correct appearance entries.
- Confirm default, dark, and tinted references point to the intended files.
- Do not pre-round artwork.

- [ ] Set the global accent to approved Royal Blue.

```bash
cp \
  "$PACKAGE_CATALOG/BrandRoyalBlue.colorset/Contents.json" \
  "$CURRENT_ACCENT/Contents.json"
```

- [ ] Validate catalog JSON.

```bash
find "$ASSET_CATALOG" -name Contents.json -print0 \
  | while IFS= read -r -d '' file; do
      plutil -lint "$file" || exit 1
    done \
  | tee .codex/evidence/brand-foundation/11-asset-json-lint.txt
```

- [ ] Verify asset names are unique.

```bash
find "$WORKTREE/For Rent" -type d \
  \( -name '*.imageset' -o -name '*.colorset' -o -name '*.appiconset' \) \
  -print \
  | sed 's#.*/##' \
  | sort \
  | uniq -d \
  | tee .codex/evidence/brand-foundation/12-duplicate-asset-names.txt

test ! -s .codex/evidence/brand-foundation/12-duplicate-asset-names.txt
```

Expected: no duplicate asset names.

---

## Task 5: Import the minimum public brand source

- [ ] Create the documentation structure.

```bash
mkdir -p \
  docs/brand/source \
  docs/brand/tokens \
  docs/brand/app-icon-masters
```

- [ ] Copy the public source-of-truth files.

```bash
cp \
  "$ASSET_SOURCE/07_BRAND_GUIDE/ForRent_QuestionMarkHome_BrandGuide_v1.0.pdf" \
  docs/brand/

cp \
  "$ASSET_SOURCE/01_MASTER_VECTOR/Symbol/for-rent-symbol-primary.svg" \
  docs/brand/source/

cp \
  "$ASSET_SOURCE/01_MASTER_VECTOR/Lockups/for-rent-one-line-horizontal-primary-no-tagline-outlined.svg" \
  docs/brand/source/

cp \
  "$ASSET_SOURCE/06_BRAND_TOKENS/for-rent-brand-tokens.json" \
  docs/brand/tokens/

cp \
  "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Default-1024.png" \
  docs/brand/app-icon-masters/

cp \
  "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Dark-1024.png" \
  docs/brand/app-icon-masters/

cp \
  "$ASSET_SOURCE/03_IOS_APP_ICON/Masters_1024/AppIcon-Tinted-Monochrome-1024.png" \
  docs/brand/app-icon-masters/
```

- [ ] Create `docs/brand/README.md` with this content:

```markdown
# For Rent Brand Identity

## Approved direction

- Concept: The Question Mark Home
- Palette: The Sign Palette
- Version: 1.0

## Approved colors

- Navy: `#0A1A3A`
- Royal Blue: `#2563EB`
- Teal: `#10B981`
- Light Gray: `#F2F4F7`
- White: `#FFFFFF`

## Runtime assets

The app consumes the approved app icon, `BrandSymbol`, `BrandLogoHorizontal`, and brand color assets through the existing Xcode asset catalog.

## Source of truth

- `ForRent_QuestionMarkHome_BrandGuide_v1.0.pdf`
- `source/for-rent-symbol-primary.svg`
- `source/for-rent-one-line-horizontal-primary-no-tagline-outlined.svg`
- `tokens/for-rent-brand-tokens.json`

## Usage

- Royal Blue carries the primary symbol and main actions.
- Navy carries wordmarks, primary text, and high-trust dark surfaces.
- Teal indicates availability and success.
- Do not redraw or alter the mark.
- Do not use Teal as the primary action color.
- Do not add unverified trust, rating, or verification marks.

## Commercial note

This repository does not claim completed trademark clearance. Complete a trademark and visual-similarity review before commercial registration or release.
```

---

## Task 6: Create semantic appearance colorsets

Create each colorset inside the existing `Assets.xcassets`. Each `Contents.json` must contain an Any Appearance color and a Dark Appearance color in sRGB.

Use these exact values:

| Asset | Light | Dark |
|---|---:|---:|
| `AppCanvas` | `#FFFFFF` | `#071225` |
| `AppSurface` | `#FFFFFF` | `#0A1A3A` |
| `AppSurfaceSubtle` | `#F2F4F7` | `#102448` |
| `AppSurfaceRaised` | `#FFFFFF` | `#142B4D` |
| `AppSurfaceSelected` | `#E8F0FF` | `#173A70` |
| `AppTextPrimary` | `#0A1A3A` | `#F8FAFC` |
| `AppTextSecondary` | `#41506A` | `#CBD5E1` |
| `AppTextMuted` | `#667085` | `#94A3B8` |
| `AppBorder` | `#D8E0EA` | `#2A4268` |
| `AppSeparator` | `#E6EBF1` | `#203655` |
| `AppActionPrimary` | `#2563EB` | `#2563EB` |
| `AppActionPressed` | `#1D4ED8` | `#1D4ED8` |
| `AppLink` | `#2563EB` | `#7CB4FF` |
| `AppFocus` | `#2563EB` | `#7CB4FF` |
| `AppSuccess` | `#0B8F65` | `#34D399` |
| `AppSuccessSurface` | `#E8FBF4` | `#0B3B2D` |
| `AppWarning` | `#8A5A00` | `#FBBF24` |
| `AppWarningSurface` | `#FFF8E6` | `#3A2A08` |
| `AppDestructive` | `#D92D20` | `#FF6961` |
| `AppDestructiveSurface` | `#FFF0F0` | `#3D1717` |

Implementation rule:

- Generate the JSON deterministically with a small temporary script or write each file explicitly.
- Do not put these hex values in feature views.
- Do not create color assets for one-off screen decoration.
- Keep brand primitives and semantic UI colors distinct.

After creating them:

```bash
find "$ASSET_CATALOG" -name Contents.json -print0 \
  | while IFS= read -r -d '' file; do
      plutil -lint "$file" || exit 1
    done
```

Expected: all asset JSON files pass.

---

## Task 7: Rebuild `ForRentDesignTokens.swift`

### Interface produced

`ForRentTheme` must expose these stable names:

```swift
enum ForRentTheme {
    enum Brand {
        static let navy: Color
        static let royalBlue: Color
        static let teal: Color
        static let lightGray: Color
        static let white: Color
    }

    enum Assets {
        static let symbol: String
        static let horizontalLogo: String
    }

    enum Colors {
        static let canvas: Color
        static let surface: Color
        static let surfaceSubtle: Color
        static let surfaceRaised: Color
        static let surfaceSelected: Color

        static let textPrimary: Color
        static let textSecondary: Color
        static let textMuted: Color

        static let border: Color
        static let separator: Color

        static let actionPrimary: Color
        static let actionPressed: Color
        static let link: Color
        static let focus: Color

        static let success: Color
        static let successSurface: Color
        static let warning: Color
        static let warningSurface: Color
        static let destructive: Color
        static let destructiveSurface: Color
    }

    enum Typography {
        static let screenTitle: Font
        static let sectionTitle: Font
        static let rowTitle: Font
        static let body: Font
        static let supporting: Font
        static let caption: Font
    }

    enum Spacing {
        static let xxs: CGFloat
        static let xs: CGFloat
        static let sm: CGFloat
        static let md: CGFloat
        static let lg: CGFloat
        static let xl: CGFloat
        static let xxl: CGFloat
        static let screenHorizontal: CGFloat
    }

    enum Radius {
        static let control: CGFloat
        static let card: CGFloat
        static let media: CGFloat
        static let pill: CGFloat
    }

    enum Control {
        static let minimumTarget: CGFloat
        static let standardHeight: CGFloat
    }

    enum Motion {
        static let fast: Double
        static let standard: Double
        static let slow: Double
    }
}
```

### Exact implementation shape

Use asset names rather than duplicating brand hex values in Swift:

```swift
import SwiftUI

enum ForRentTheme {
    enum Brand {
        static let navy = Color("BrandNavy")
        static let royalBlue = Color("BrandRoyalBlue")
        static let teal = Color("BrandTeal")
        static let lightGray = Color("BrandLightGray")
        static let white = Color("BrandWhite")
    }

    enum Assets {
        static let symbol = "BrandSymbol"
        static let horizontalLogo = "BrandLogoHorizontal"
    }

    enum Colors {
        static let canvas = Color("AppCanvas")
        static let surface = Color("AppSurface")
        static let surfaceSubtle = Color("AppSurfaceSubtle")
        static let surfaceRaised = Color("AppSurfaceRaised")
        static let surfaceSelected = Color("AppSurfaceSelected")

        static let textPrimary = Color("AppTextPrimary")
        static let textSecondary = Color("AppTextSecondary")
        static let textMuted = Color("AppTextMuted")

        static let border = Color("AppBorder")
        static let separator = Color("AppSeparator")

        static let actionPrimary = Color("AppActionPrimary")
        static let actionPressed = Color("AppActionPressed")
        static let link = Color("AppLink")
        static let focus = Color("AppFocus")

        static let success = Color("AppSuccess")
        static let successSurface = Color("AppSuccessSurface")
        static let warning = Color("AppWarning")
        static let warningSurface = Color("AppWarningSurface")
        static let destructive = Color("AppDestructive")
        static let destructiveSurface = Color("AppDestructiveSurface")

        // Compatibility aliases for existing screens.
        static let primary = Brand.navy
        static let primaryActive = Brand.navy
        static let action = actionPrimary
        static let actionActive = actionPressed
        static let ink = textPrimary
        static let body = textSecondary
        static let muted = textMuted
        static let surfaceSoft = surfaceSubtle
        static let surfaceStrong = surfaceSelected
        static let hairline = separator
        static let borderStrong = border
        static let coral = destructive
        static let forest = success
        static let cream = surfaceSelected
        static let peach = destructiveSurface
        static let mint = successSurface
        static let yellow = warning
        static let mustard = warning
        static let linkActive = actionPressed
    }

    enum Typography {
        static let screenTitle = Font.largeTitle.weight(.bold)
        static let sectionTitle = Font.headline
        static let rowTitle = Font.body.weight(.semibold)
        static let body = Font.body
        static let supporting = Font.subheadline
        static let caption = Font.caption
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let screenHorizontal: CGFloat = 16
    }

    enum Radius {
        static let control: CGFloat = 12
        static let card: CGFloat = 16
        static let media: CGFloat = 12
        static let pill: CGFloat = 999
    }

    enum Control {
        static let minimumTarget: CGFloat = 44
        static let standardHeight: CGFloat = 52
    }

    enum Motion {
        static let fast = 0.10
        static let standard = 0.20
        static let slow = 0.25
    }
}
```

Do not remove compatibility aliases in this PR. Their purpose is to apply the new brand through existing screens without forcing a broad unrelated rewrite.

---

## Task 8: Add `ForRentBrandAsset.swift`

Create `For Rent/DesignSystem/ForRentBrandAsset.swift`:

```swift
import SwiftUI

struct ForRentBrandAsset: View {
    enum Kind {
        case symbol
        case horizontalLogo
    }

    let kind: Kind
    var accessibilityLabel: String? = nil

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
            .accessibilityLabel(accessibilityLabel ?? defaultAccessibilityLabel)
    }

    private var assetName: String {
        switch kind {
        case .symbol:
            ForRentTheme.Assets.symbol
        case .horizontalLogo:
            ForRentTheme.Assets.horizontalLogo
        }
    }

    private var defaultAccessibilityLabel: String {
        switch kind {
        case .symbol:
            "For Rent"
        case .horizontalLogo:
            "For Rent"
        }
    }
}
```

Rules:

- Do not apply template rendering to the primary full-color identity assets.
- Do not use the app icon as an in-app logo.
- Decorative repeats must use `.accessibilityHidden(true)` at the call site.
- Identity uses should expose the brand name once, not repeatedly.

---

## Task 9: Write theme tests before changing components

Create `For RentTests/ForRentThemeTests.swift`.

Test requirements:

1. Resolve brand colors through `UIColor`.
2. Assert exact light appearance RGB values for the five approved brand primitives.
3. Assert light and dark semantic text/canvas pairs resolve differently where expected.
4. Assert action primary remains approved Royal Blue in both appearances.
5. Assert semantic colors exist and do not resolve to clear.

Use `UITraitCollection(userInterfaceStyle:)` and a helper that extracts sRGB components.

Minimum test names:

```swift
func test_brandColorsMatchApprovedPalette()
func test_semanticCanvasAndTextResolveForLightAndDark()
func test_primaryActionUsesApprovedRoyalBlue()
func test_semanticColorsAreNotClear()
```

Because `For RentTests` is not a synchronized group:

- Add a `PBXFileReference`.
- Add a `PBXBuildFile`.
- Add the file reference to the `For RentTests` group.
- Add the build file to the unit-test Sources phase.
- Use unique 24-character project IDs.
- Run `xcodebuild -list` immediately after editing the project file.

Run the focused tests:

```bash
xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -only-testing:'For RentTests/ForRentThemeTests' \
  -parallel-testing-enabled NO
```

Expected: tests fail before the semantic asset and theme implementation is complete, then pass after Tasks 6 to 8.

---

## Task 10: Update shared buttons and global tint

Modify `For Rent/Views/Components/ButtonStyles.swift`.

Required changes:

1. Read `accessibilityReduceMotion`.
2. Use `ForRentTheme.Control.standardHeight`.
3. Use `ForRentTheme.Colors.actionPrimary` and `actionPressed`.
4. Disabled primary buttons use `surfaceSubtle` and `textMuted`.
5. Secondary buttons use `surface`, `border`, and `textPrimary`.
6. Do not animate scale when Reduce Motion is enabled.
7. Keep the content shape and 44-point minimum target.

Expected behavior:

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion
```

Animation decision:

```swift
.animation(
    reduceMotion ? nil : .easeOut(duration: ForRentTheme.Motion.fast),
    value: configuration.isPressed
)
```

Modify `For Rent/ContentView.swift`:

```swift
.tint(ForRentTheme.Colors.actionPrimary)
```

Modify `For Rent/Views/Landlord/LandlordTabView.swift`:

- Remove `.tint(.black)`.
- Do not add another local tint override.

Build immediately after these changes.

---

## Task 11: Apply the approved lockup to Login

Modify the header in `For Rent/Views/Auth/LoginView.swift`.

Replace the system building symbol, separate title, and old tagline with:

- `ForRentBrandAsset(kind: .horizontalLogo)`
- Maximum visual width around 260 points on compact iPhone
- A fixed accessible aspect ratio determined by the actual asset
- Supporting copy: `Find your answer. Find your place.`
- Navy or Royal Blue branded header treatment that remains readable in light and dark appearances
- No yellow brand treatment
- No duplicate visible `For Rent` text if the horizontal logo already contains the wordmark

The demo chooser remains functionally unchanged in PR 1.

Required accessibility:

- The lockup is read once as `For Rent`.
- The supporting tagline is separate text.
- Decorative copies are hidden from VoiceOver.

---

## Task 12: Update design documentation

Replace the old core palette in `DESIGN.md` with:

- Approved brand primitives
- Semantic light/dark tokens
- Asset naming rules
- App-icon rules
- Logo clear-space and misuse rules
- Typography remains SF system styles
- Teal is a success/availability accent
- Royal Blue is the primary action
- Navy is primary text and high-trust dark surface
- No direct hex values in feature views
- Compatibility aliases are temporary and must not be used in new code

Add an Unreleased entry to `CHANGELOG.md`:

```markdown
### Added
- Approved Question Mark Home logo, app icon, and runtime brand assets.
- Semantic light and dark color tokens based on The Sign Palette.

### Changed
- Replaced the previous blue theme foundation with the approved For Rent identity.
- Updated global action tint and shared button states.
- Applied the approved logo to the authentication entry screen.
```

Do not add screenshot or release claims.

---

## Task 13: Verify PR 1

Run:

```bash
git diff --check
git status --short --branch

npm run scan:secrets
npm run validate:demo
npm run test:firebase

xcodebuild -list -project "For Rent.xcodeproj"

xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -parallel-testing-enabled NO
```

Manual simulator checks:

- Default app icon
- Dark app icon if the installed Xcode supports it
- Tinted icon if the installed Xcode supports it
- Login in light appearance
- Login in dark appearance
- Large Dynamic Type
- Reduce Motion
- High Contrast
- Landlord tab selection uses Royal Blue, not black
- Existing screens still render with semantic aliases

Capture evidence to `.codex/evidence/brand-foundation/`.

Commit sequence:

```bash
git add "For Rent" docs/brand DESIGN.md CHANGELOG.md "For RentTests" "For Rent.xcodeproj/project.pbxproj"
git commit -m "feat(brand): import Question Mark Home assets"

git add "For Rent/DesignSystem" "For Rent/Views/Components/ButtonStyles.swift" "For Rent/ContentView.swift" "For Rent/Views/Landlord/LandlordTabView.swift" "For RentTests/ForRentThemeTests.swift" "For Rent.xcodeproj/project.pbxproj"
git commit -m "refactor(theme): add semantic brand tokens"

git add "For Rent/Views/Auth/LoginView.swift" DESIGN.md CHANGELOG.md
git commit -m "feat(auth): apply approved For Rent lockup"
```

Before opening the PR:

```bash
git status --short --branch
git log --oneline --decorate -5
git diff origin/dev...HEAD --stat
```

---

# PR 2: Profile editor state and persistence

## Task 14: Sync `dev` and create the second worktree

After PR 1 is merged:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
git -C "$REPO_ROOT" fetch origin --prune
git -C "$REPO_ROOT" switch dev
git -C "$REPO_ROOT" pull --ff-only origin dev

WORKTREE_ROOT="$(dirname "$REPO_ROOT")/.worktrees"
BRANCH="refactor/for-rent__profile-editor-state"
WORKTREE="$WORKTREE_ROOT/for-rent-profile-editor-state"

git -C "$REPO_ROOT" worktree add "$WORKTREE" -b "$BRANCH" origin/dev
cd "$WORKTREE"
```

Run the baseline build and existing tests before editing.

---

## Task 15: Define the profile editor contract

Create `For Rent/ViewModels/ProfileEditor.swift`.

### Required types

```swift
import Foundation
import Observation

struct ProfileDraft: Equatable {
    var firstName: String
    var lastName: String
    var phone: String

    init(user: AppUser) {
        firstName = user.firstName
        lastName = user.lastName
        phone = user.phone
    }

    var normalized: ProfileDraft {
        ProfileDraft(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            phone: Self.normalizedPhone(phone)
        )
    }

    private init(firstName: String, lastName: String, phone: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
    }

    private static func normalizedPhone(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\u{2013}", with: "-")
            .replacingOccurrences(of: "\u{2014}", with: "-")
    }
}

struct ProfileFieldErrors: Equatable {
    var firstName: String?
    var lastName: String?
    var phone: String?

    var hasErrors: Bool {
        firstName != nil || lastName != nil || phone != nil
    }
}

enum ProfileSubmissionState: Equatable {
    case idle
    case saving
    case failed(message: String)
}

@MainActor
@Observable
final class ProfileEditor {
    private(set) var original: ProfileDraft
    var draft: ProfileDraft
    private(set) var errors = ProfileFieldErrors()
    private(set) var submissionState: ProfileSubmissionState = .idle

    init(user: AppUser) {
        let draft = ProfileDraft(user: user)
        original = draft.normalized
        self.draft = draft
    }

    var hasChanges: Bool {
        draft.normalized != original
    }

    var isSaving: Bool {
        submissionState == .saving
    }

    var canSave: Bool {
        hasChanges && validationErrors(for: draft.normalized).hasErrors == false && !isSaving
    }

    @discardableResult
    func validate() -> Bool {
        errors = validationErrors(for: draft.normalized)
        return !errors.hasErrors
    }

    func beginSaving() {
        submissionState = .saving
    }

    func finishSaving(user: AppUser) {
        let saved = ProfileDraft(user: user).normalized
        original = saved
        draft = saved
        errors = ProfileFieldErrors()
        submissionState = .idle
    }

    func fail(_ error: Error) {
        submissionState = .failed(message: error.localizedDescription)
    }

    func clearSubmissionError() {
        if case .failed = submissionState {
            submissionState = .idle
        }
    }

    private func validationErrors(for draft: ProfileDraft) -> ProfileFieldErrors {
        var errors = ProfileFieldErrors()

        if draft.firstName.isEmpty {
            errors.firstName = "Enter a first name."
        }

        if draft.lastName.isEmpty {
            errors.lastName = "Enter a last name."
        }

        if !draft.phone.isEmpty {
            let allowed = CharacterSet(charactersIn: "+0123456789()-. ")
            if draft.phone.unicodeScalars.contains(where: { !allowed.contains($0) }) {
                errors.phone = "Use digits and common phone punctuation only."
            } else {
                let digitCount = draft.phone.filter(\.isNumber).count
                if !(7...15).contains(digitCount) {
                    errors.phone = "Enter a phone number with 7 to 15 digits."
                }
            }
        }

        return errors
    }
}
```

Notes:

- If the repository cannot compile `Observation` under the verified current language mode, use `ObservableObject` with `@Published` without changing the public behavior.
- Do not change the deployment target or Swift language mode to solve a local compiler issue.
- Store the user's normalized but recognizably formatted phone string.
- Do not force a North American phone format.
- Phone remains optional.

---

## Task 16: Write failing unit tests

Create `For RentTests/ProfileEditorTests.swift`.

Required tests:

```swift
func test_initialDraftMatchesUserAndHasNoChanges()
func test_whitespaceOnlyNameIsInvalid()
func test_validEditEnablesSave()
func test_unchangedNormalizedValuesDoNotEnableSave()
func test_emptyPhoneIsAllowed()
func test_phoneRejectsUnsupportedCharacters()
func test_phoneRequiresSevenToFifteenDigitsWhenPresent()
func test_beginSavingDisablesSave()
func test_finishSavingResetsDirtyState()
func test_failurePreservesDraft()
```

Use a deterministic fixture:

```swift
private let user = AppUser(
    id: "landlord-demo",
    email: "marc.dubois@example.invalid",
    role: .landlord,
    firstName: "Marc",
    lastName: "Dubois",
    phone: "514-555-0112",
    shortlisted: []
)
```

Add the file to the test target through `project.pbxproj`.

Run focused tests. Expected: fail before implementation, pass after implementation.

---

## Task 17: Convert profile update persistence to an explicit result

Modify `AuthViewModel.updateProfile`.

### New signature

```swift
func updateProfile(
    firstName: String,
    lastName: String,
    phone: String
) async throws -> AppUser
```

Required behavior:

1. Guard that a current user exists. Throw a localized `ProfileUpdateError.notAuthenticated`.
2. Trim first and last name.
3. Normalize the phone dash characters and outer whitespace.
4. Validate required names.
5. In demo mode:
   - Call `DemoSession.updateProfile`.
   - Update `user`.
   - Return the updated user.
   - Do not set `successMessage`.
6. In Firebase mode:
   - Set `isLoading = true`.
   - Use `defer { isLoading = false }`.
   - Call `FirestoreService.shared.updateProfile`.
   - Update `user`.
   - Return the updated user.
   - Do not clear the current user on profile update failure.
7. Throw failures to the caller.
8. Do not write role or email.
9. Do not use global `errorMessage` or `successMessage` as the save result.

Create an internal error:

```swift
enum ProfileUpdateError: LocalizedError {
    case notAuthenticated
    case requiredName

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "Sign in before updating your profile."
        case .requiredName:
            "First and last name are required."
        }
    }
}
```

Update the old `EditProfileView` temporarily so the branch compiles:

- Call the throwing method in `do/catch`.
- Preserve its current UI.
- Assign any caught message to local state or `authVM.errorMessage`.
- Do not redesign the screen in PR 2.

This temporary call-site adaptation will be replaced in PR 3.

---

## Task 18: Add persistence tests

Extend `ProfileEditorTests.swift` or create `AuthProfileUpdateTests.swift` if a narrow environment seam is practical.

Coverage must prove:

1. Demo update changes first name, last name, and phone.
2. Demo update returns the updated user.
3. Demo update does not change email.
4. Demo update does not change role.
5. Demo reset restores the seed profile.
6. Firebase profile update failure preserves the previous `user` in memory.
7. Empty required names fail before persistence.

Do not introduce a broad service abstraction only for one test. Prefer the existing `AppEnvironment` demo seam. If Firebase failure cannot be unit-tested without a focused injection seam, add only a `ProfileStore` protocol with:

```swift
protocol ProfileStore {
    func updateProfile(
        userId: String,
        firstName: String,
        lastName: String,
        phone: String
    ) async throws
}
```

Production adapter delegates to `FirestoreService.shared`. Demo behavior remains in `DemoSession`.

---

## Task 19: Verify PR 2

Run the full required gates plus focused tests.

Manual checks:

- Existing Edit Profile still loads.
- Valid demo update changes the displayed user.
- Invalid names do not persist.
- Firebase failures do not sign the user out.
- Reset Demo restores the original demo profile.

Commit sequence:

```bash
git add "For Rent/ViewModels/ProfileEditor.swift" "For RentTests/ProfileEditorTests.swift" "For Rent.xcodeproj/project.pbxproj"
git commit -m "test(profile): define editor state coverage"

git add "For Rent/ViewModels/ProfileEditor.swift"
git commit -m "feat(profile): add validated profile draft state"

git add "For Rent/ViewModels/AuthViewModel.swift" "For Rent/Views/Shared/EditProfileView.swift" "For Rent/Services/AppEnvironment.swift" "For RentTests" CHANGELOG.md
git commit -m "refactor(profile): return explicit update results"
```

---

# PR 3: Account and Personal Details redesign

## Task 20: Sync `dev` and create the third worktree

After PR 2 is merged:

```bash
REPO_ROOT="$(git rev-parse --show-toplevel)"
git -C "$REPO_ROOT" fetch origin --prune
git -C "$REPO_ROOT" switch dev
git -C "$REPO_ROOT" pull --ff-only origin dev

WORKTREE_ROOT="$(dirname "$REPO_ROOT")/.worktrees"
BRANCH="feat/for-rent__account-personal-details"
WORKTREE="$WORKTREE_ROOT/for-rent-account-personal-details"

git -C "$REPO_ROOT" worktree add "$WORKTREE" -b "$BRANCH" origin/dev
cd "$WORKTREE"
```

Run baseline build and tests.

---

## Task 21: Add display helpers to `AppUser`

Create `For Rent/Models/AppUser+Display.swift`:

```swift
import Foundation

extension AppUser {
    var displayName: String {
        let parts = [firstName, lastName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return parts.isEmpty ? "Account" : parts.joined(separator: " ")
    }

    var initials: String {
        let characters = [firstName, lastName]
            .compactMap { value in
                value
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .first
            }

        let result = String(characters.prefix(2)).uppercased()
        return result.isEmpty ? "FR" : result
    }

    var roleDisplayName: String {
        switch role {
        case .guest:
            "Guest"
        case .tenant:
            "Renter"
        case .landlord:
            "Landlord"
        }
    }

    var formattedPhoneForDisplay: String? {
        let value = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
```

Add unit tests to an existing unit-test file or a new target-member file:

```swift
func test_displayNameUsesFirstAndLastName()
func test_initialsUseUpToTwoNameCharacters()
func test_emptyNameFallsBackToAccountAndFR()
func test_tenantRoleDisplaysAsRenter()
func test_emptyPhoneReturnsNil()
```

---

## Task 22: Create `AccountIdentityHeader`

Create `For Rent/Views/Components/AccountIdentityHeader.swift`.

### Interface

```swift
struct AccountIdentityHeader: View {
    let user: AppUser
    let isDemoMode: Bool
}
```

### Required layout

- Horizontal layout at standard Dynamic Type.
- Avatar:
  - 60 by 60 minimum.
  - Royal Blue background.
  - White initials.
  - Circle.
- Identity:
  - `user.displayName` using `rowTitle` or headline.
  - `user.roleDisplayName`.
  - Demo badge only if `isDemoMode`.
  - Email as secondary text.
- At accessibility text sizes:
  - Use `ViewThatFits` or a layout that moves metadata below.
  - Do not truncate the full name before allowing wrapping.
  - Email may wrap and use an accessibility label.
- Card:
  - `surfaceRaised`
  - border
  - 16-point radius
  - no heavy custom shadow
- The header is not a button.
- Do not show fake verified icons.

Accessibility label example:

```text
Marc Dubois, Landlord, Demo account, marc.dubois@example.invalid
```

---

## Task 23: Create reusable account rows

Create `For Rent/Views/Components/AccountRow.swift`.

Required types:

```swift
struct AccountNavigationRow: View {
    let icon: String
    let title: String
    let value: String?
    let supportingText: String?
}

struct AccountInformationRow: View {
    let icon: String
    let title: String
    let value: String
    let supportingText: String?
}
```

Rules:

- Minimum 44-point target for navigation rows.
- SF Symbol uses Royal Blue for normal navigation.
- Primary title uses `textPrimary`.
- Value and supporting text use `textSecondary`.
- Chevron is decorative and hidden from VoiceOver.
- Entire navigation row is one accessible element.
- Do not put destructive styling in the reusable normal row.
- Do not put card containers inside `List` row cards unless required by the approved layout.

---

## Task 24: Build `AccountView`

Create `For Rent/Views/Shared/AccountView.swift`.

### State

```swift
@EnvironmentObject private var authVM: AuthViewModel
@EnvironmentObject private var feedbackCenter: FeedbackCenter

@State private var confirmation: Confirmation?
```

Use one enum rather than multiple booleans:

```swift
private enum Confirmation: String, Identifiable {
    case resetDemo
    case signOut

    var id: String { rawValue }
}
```

### Structure

Use a native `List` with inset grouping and a branded background:

```text
Account
  Identity header

Personal Information
  Personal details
  Marc Dubois · 514-555-0112

Account
  Email
  marc.dubois@example.invalid
  Managed by your sign-in account

Demo
  Reset demo data
  Restore profiles, listings, saved homes, and requests

Session
  Sign Out
```

### Required behavior

1. Navigation title is `Account`.
2. Personal Details row navigates only when `authVM.user` exists.
3. Personal Details value:
   - Full name
   - Phone appended only if present
4. Email is informational and read-only.
5. Show `Demo account` supporting copy when demo mode is active.
6. Reset Demo section appears only in demo mode.
7. Reset action presents:

```text
Reset demo data?

This restores demo profiles, properties, saved homes, and requests to their starting state. You will stay signed in as the current demo role.

Cancel
Reset Demo
```

8. On reset:
   - Call `authVM.resetDemo()`.
   - Show `Demo data restored.` through `FeedbackCenter`.
9. Sign Out presents:

```text
Sign out of For Rent?

Cancel
Sign Out
```

10. On sign out:
    - Call `authVM.logout()`.
    - Do not leave Account in navigation history.
11. Destructive actions use SwiftUI button roles.
12. Do not use plain red text floating in empty space.
13. Do not show Reset Demo for Firebase users.
14. Do not show role as editable.

### Accessibility identifiers

Add stable identifiers:

```text
account.screen
account.identity
account.personalDetails
account.email
account.resetDemo
account.signOut
account.confirmReset
account.confirmSignOut
```

---

## Task 25: Build `PersonalDetailsView`

Create `For Rent/Views/Shared/PersonalDetailsView.swift`.

### Interface

```swift
struct PersonalDetailsView: View {
    let user: AppUser
}
```

### State ownership

```swift
@Environment(\.dismiss) private var dismiss
@EnvironmentObject private var authVM: AuthViewModel
@EnvironmentObject private var feedbackCenter: FeedbackCenter

@State private var editor: ProfileEditor
@State private var showsDiscardConfirmation = false
```

Initialize the editor in `init(user:)`.

### Form sections

1. `Name`
   - First name
   - Last name
2. `Contact`
   - Phone number
   - Supporting copy: `Used for account and inquiry communication.`
3. `Account Email`
   - Read-only email
   - Supporting copy: `Email changes are not supported here.`
   - If demo: `This is demo account data.`

### Field requirements

First name:

```swift
.textContentType(.givenName)
.textInputAutocapitalization(.words)
.submitLabel(.next)
```

Last name:

```swift
.textContentType(.familyName)
.textInputAutocapitalization(.words)
.submitLabel(.next)
```

Phone:

```swift
.textContentType(.telephoneNumber)
.keyboardType(.phonePad)
.submitLabel(.done)
```

Use persistent visible labels. Do not rely on placeholder-only labels.

Show field errors directly below the corresponding field using:

- `destructive` color
- error icon
- full text
- accessibility live-region behavior where supported

### Toolbar

- Leading: Back or Cancel action.
- Center: `Personal Details`.
- Trailing: `Save`.
- Save is disabled unless `editor.canSave`.
- While saving:
  - Disable form controls.
  - Replace Save label with a compact progress indicator or `Saving`.
  - Prevent duplicate submission.
- Hide the tab bar:

```swift
.toolbar(.hidden, for: .tabBar)
```

### Save behavior

```swift
private func save() {
    guard editor.validate() else { return }

    editor.beginSaving()

    Task {
        do {
            let updatedUser = try await authVM.updateProfile(
                firstName: editor.draft.firstName,
                lastName: editor.draft.lastName,
                phone: editor.draft.phone
            )
            editor.finishSaving(user: updatedUser)
            feedbackCenter.show(.success("Profile updated."))
            dismiss()
        } catch {
            editor.fail(error)
        }
    }
}
```

### Failure behavior

- Remain on the form.
- Preserve entered values.
- Show an inline or top-of-form error summary based on `submissionState`.
- Provide a dismiss button for the error message.
- Do not use a blocking success alert.
- Do not clear fields.

### Unsaved-change behavior

Always route the custom back action through:

```swift
private func attemptDismiss() {
    if editor.hasChanges {
        showsDiscardConfirmation = true
    } else {
        dismiss()
    }
}
```

Confirmation:

```text
Discard changes?

Your profile updates have not been saved.

Keep Editing
Discard Changes
```

Rules:

- Hide the default back button only if required to guarantee the check.
- Preserve a standard back-chevron affordance.
- Do not use a close icon if the screen remains a push destination.
- Confirm that edge-swipe back cannot bypass the dirty-state warning.
- If edge-swipe cannot be safely intercepted with the current push approach, present Personal Details as a full-screen sheet with Cancel and Save instead. Do not ship a path that silently discards edits.

### Accessibility identifiers

```text
personalDetails.screen
personalDetails.firstName
personalDetails.firstNameError
personalDetails.lastName
personalDetails.lastNameError
personalDetails.phone
personalDetails.phoneError
personalDetails.email
personalDetails.save
personalDetails.cancel
personalDetails.discardConfirmation
```

---

## Task 26: Replace old screens and rename tabs

Modify `For Rent/Views/Landlord/LandlordTabView.swift`:

```swift
NavigationStack {
    AccountView()
}
.tabItem {
    Label("Account", systemImage: "person.crop.circle")
}
```

Modify `For Rent/Views/Tenant/TenantTabView.swift` the same way.

Rules:

- Do not set `.navigationTitle("Account")` in both tab shell and child if it causes duplicate configuration.
- `AccountView` owns its title.
- Keep one `NavigationStack` owner per tab.
- Do not add Account to guest navigation.
- Remove references to `ProfileView`.
- After build and tests pass, delete:
  - `For Rent/Views/Shared/ProfileView.swift`
  - `For Rent/Views/Shared/EditProfileView.swift`

Run:

```bash
rg -n "ProfileView|EditProfileView|navigationTitle\(\"Profile\"\)|Label\(\"Profile\"" "For Rent" "For RentTests" "For RentUITests"
```

Expected: no stale references.

---

## Task 27: Add account flow UI coverage

Extend `For RentUITests/ForRentSmokeTests.swift`.

Do not create another UI-test file unless target membership is added correctly.

Required test:

```swift
func test_landlordCanEditProfileAndResetDemo()
```

Test flow:

1. Launch app.
2. Wait for `Explore the demo`.
3. Tap the landlord demo account using its visible name or stable accessibility identifier.
4. Tap the `Account` tab.
5. Assert `account.screen`.
6. Assert identity displays Marc Dubois and Landlord.
7. Tap `account.personalDetails`.
8. Replace first name with `Marcus`.
9. Assert Save becomes enabled.
10. Tap Save.
11. Assert return to `account.screen`.
12. Assert updated name appears.
13. Tap `account.resetDemo`.
14. Assert confirmation appears.
15. Cancel once and verify no reset.
16. Open reset confirmation again.
17. Confirm Reset Demo.
18. Assert original `Marc Dubois` appears.
19. Assert the success feedback appears if it is exposed accessibly.

Add a second focused test:

```swift
func test_personalDetailsPreventsInvalidSave()
```

Flow:

1. Open landlord Personal Details.
2. Clear first name.
3. Trigger validation.
4. Assert `personalDetails.firstNameError`.
5. Assert the editor remains open.
6. Assert no updated identity appears.

Use accessibility identifiers rather than coordinate taps.

---

## Task 28: Manual design and accessibility QA

Test at minimum:

### Devices

- Compact iPhone simulator
- Current Pro-size iPhone simulator
- iPad layout sanity check because the target supports device family 1 and 2

### Appearance

- Light
- Dark
- Increased Contrast
- Bold Text
- Reduce Motion
- Reduce Transparency

### Dynamic Type

- Default
- Extra Extra Extra Large
- Accessibility Medium
- Accessibility Extra Extra Extra Large

### VoiceOver

Verify order:

1. Navigation title
2. Identity header as one coherent group
3. Personal Information section
4. Account section
5. Demo section when present
6. Session section

### Content cases

- Long first and last name
- Long email
- Empty phone
- Valid international-style phone
- Demo account
- Firebase account
- Landlord role
- Tenant role
- Save in progress
- Save failure
- Unsaved changes
- Reset confirmation
- Sign-out confirmation

### Visual acceptance

- No large blank region between content and tab bar.
- No floating text buttons.
- No duplicate Profile or Account titles.
- No tab bar on Personal Details.
- No clipped identity metadata.
- No low-contrast disabled Save.
- No white text on Teal success backgrounds.
- No hard-coded black tint.
- No direct feature-view hex colors.
- No brand symbol used as an action icon.
- No cards inside cards.

---

## Task 29: Update documentation

Create `docs/10_ACCOUNT_PROFILE_REDESIGN.md` with:

1. Problem summary
2. Final information architecture
3. Screen responsibilities
4. Read-only account fields
5. Demo reset behavior
6. Sign-out behavior
7. Profile editor state machine
8. Validation rules
9. Accessibility identifiers
10. Test matrix
11. Known non-goals
12. Rollback instructions

Update `DESIGN.md`:

- Add Account and Personal Details component rules.
- Document initials avatar.
- Document section order.
- Document destructive-action separation.
- Document no profile image in current scope.
- Document field label and error rules.

Update `docs/09_DEMO_CAPTURE_PACK.md` with a capture checklist:

- Account light
- Account dark
- Personal Details light
- Personal Details dark
- Reset confirmation
- Invalid field state
- Updated name after save

Do not add images until real simulator captures exist.

Update `CHANGELOG.md`:

```markdown
### Added
- Branded Account and Personal Details experiences for renter and landlord roles.
- Validated profile draft state, dirty-state protection, and typed submission feedback.
- Confirmations for demo reset and sign out.
- Account profile UI coverage and accessibility identifiers.

### Changed
- Renamed the shared Profile tab to Account.
- Replaced the previous unstructured profile actions with grouped account information.
- Replaced the basic edit form with a focused Personal Details flow.
```

---

## Task 30: Full verification and PR evidence

Run all required checks:

```bash
git diff --check
git status --short --branch

npm run scan:secrets
npm run validate:demo
npm run test:firebase

xcodebuild -list -project "For Rent.xcodeproj"

xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO

xcodebuild test \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -parallel-testing-enabled NO
```

Also run release configuration:

```bash
xcodebuild build \
  -project "For Rent.xcodeproj" \
  -scheme "For Rent" \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

Search for regressions:

```bash
rg -n '\.tint\(\.black\)|Color\(hex:|foregroundColor\(\.gray\)|ProfileView|EditProfileView' "For Rent"
```

Interpretation:

- `.tint(.black)` must be absent.
- Direct `Color(hex:)` calls must remain confined to approved token internals if still needed.
- `ProfileView` and `EditProfileView` references must be absent.
- Generic gray use in the touched Account flow must be absent.

Asset verification:

```bash
find "For Rent" -type d -name 'AppIcon.appiconset' -print
find "For Rent" -type d -name 'BrandSymbol.imageset' -print
find "For Rent" -type d -name 'BrandLogoHorizontal.imageset' -print
```

Expected:

- Exactly one `AppIcon.appiconset`.
- Exactly one `BrandSymbol.imageset`.
- Exactly one `BrandLogoHorizontal.imageset`.

App-icon property verification:

```bash
find "For Rent" -path '*AppIcon.appiconset/*.png' -print0 \
  | while IFS= read -r -d '' file; do
      sips -g pixelWidth -g pixelHeight -g hasAlpha "$file"
    done \
  | tee .codex/evidence/account-profile/app-icon-properties.txt
```

Manual capture must record:

- Simulator and OS
- Appearance
- Dynamic Type setting
- Commit SHA
- Screen state
- Whether the image is approved for README use

---

# 6. Commit plan for PR 3

Use this sequence:

```bash
git add "For Rent/Models/AppUser+Display.swift" "For Rent/Views/Components/AccountIdentityHeader.swift" "For Rent/Views/Components/AccountRow.swift" "For RentTests" "For Rent.xcodeproj/project.pbxproj"
git commit -m "feat(account): add identity and row components"

git add "For Rent/Views/Shared/AccountView.swift" "For Rent/Views/Landlord/LandlordTabView.swift" "For Rent/Views/Tenant/TenantTabView.swift"
git commit -m "feat(account): add grouped account experience"

git add "For Rent/Views/Shared/PersonalDetailsView.swift" "For Rent/ViewModels/ProfileEditor.swift" "For Rent/ViewModels/AuthViewModel.swift"
git commit -m "feat(profile): add focused personal details editor"

git rm "For Rent/Views/Shared/ProfileView.swift" "For Rent/Views/Shared/EditProfileView.swift"
git commit -m "refactor(profile): remove legacy profile screens"

git add "For RentUITests/ForRentSmokeTests.swift" docs DESIGN.md CHANGELOG.md
git commit -m "test(account): cover profile and demo reset flow"
```

If a commit does not build independently, squash or reorder before opening the PR. Do not leave a commit that intentionally breaks the branch.

---

# 7. Pull request acceptance checklist

## PR 1

- [ ] Brand package checksum verified.
- [ ] Only runtime assets and selected source files imported.
- [ ] Exactly one AppIcon asset exists.
- [ ] App icon builds.
- [ ] Default icon is approved artwork.
- [ ] Dark and tinted variants integrated only where supported by verified schema.
- [ ] Accent color is Royal Blue.
- [ ] Semantic colorsets exist for light and dark.
- [ ] Theme exposes brand, semantic color, typography, spacing, radius, control, and motion tokens.
- [ ] Existing token names remain compatible.
- [ ] Shared buttons handle disabled state and Reduce Motion.
- [ ] Landlord black tint override removed.
- [ ] Login uses approved lockup.
- [ ] Light and dark mode reviewed.
- [ ] Unit tests pass.
- [ ] Required repo gates pass.

## PR 2

- [ ] Profile editor owns original and draft values.
- [ ] Dirty state uses normalized values.
- [ ] Required-name validation works.
- [ ] Optional phone validation accepts common international punctuation.
- [ ] Saving state prevents duplicates.
- [ ] Failure preserves draft.
- [ ] Demo update returns updated user.
- [ ] Firebase failure preserves user.
- [ ] Email and role are immutable.
- [ ] Reset restores demo seed.
- [ ] Unit tests pass.
- [ ] Required repo gates pass.

## PR 3

- [ ] Profile tab renamed Account for tenant and landlord.
- [ ] Account uses grouped information architecture.
- [ ] Identity header uses initials.
- [ ] Demo badge is conditional.
- [ ] Email and role are read-only.
- [ ] Reset Demo has accurate explanation and confirmation.
- [ ] Sign Out has confirmation.
- [ ] Personal Details hides tab bar.
- [ ] Save is disabled until changed and valid.
- [ ] Save returns to refreshed Account.
- [ ] Save failure preserves input.
- [ ] Unsaved changes require confirmation.
- [ ] Old profile screens removed.
- [ ] Accessibility identifiers and labels exist.
- [ ] UI tests cover save, invalid state, cancel, and reset.
- [ ] Light, dark, Dynamic Type, VoiceOver, and Reduce Motion reviewed.
- [ ] Documentation updated.
- [ ] Required repo gates pass.

---

# 8. Rollback strategy

## Brand rollback

Restore the preserved `AppIcon.appiconset` and `AccentColor.colorset`, remove imported brand imagesets/colorsets, and revert the token commit. Because the old token names remain as compatibility aliases, rollback should not require feature-screen changes.

## Profile state rollback

Revert the explicit throwing update method and `ProfileEditor` commit while retaining the brand foundation. Verify demo and Firebase login before reopening profile work.

## Account UI rollback

Restore `ProfileView.swift` and `EditProfileView.swift`, switch tab references back, and keep the new brand tokens. Do not roll back the brand foundation solely because the Account UI needs adjustment.

---

# 9. Final owner review

Before the final `dev` to `main` PR:

1. Re-run all repository gates on a clean `dev`.
2. Verify the app icon on a real device if available.
3. Review Account and Personal Details in light and dark.
4. Review the landlord and tenant paths.
5. Verify demo reset scope.
6. Verify sign out returns to the correct chooser or authentication screen.
7. Verify no screenshot or release claim was added without evidence.
8. Review the diff for unrelated files.
9. Record exact commit SHA and test commands in the PR.
10. Wait for Yash's explicit merge approval.

---

# 10. Codex launch prompt

Copy this prompt into Codex with this plan available in the repository:

```text
Activate Zeref OS for the For Rent iOS repository.

Read in this order:
1. AGENTS.md
2. docs/superpowers/plans/2026-07-11-for-rent-brand-account-profile-redesign.md
3. DESIGN.md
4. README.md
5. The relevant source and test files named in the plan
6. /Users/yashkanadhia/Documents/Dev-Projects/IOS/ForRent_QuestionMarkHome_BrandAssets_v1.0/README.md
7. /Users/yashkanadhia/Documents/Dev-Projects/IOS/ForRent_QuestionMarkHome_BrandAssets_v1.0/SHA256SUMS.txt

Execute the plan task by task using an isolated worktree and TDD. Start with PR 1 only:
feat/for-rent__question-mark-brand-foundation

Do not begin PR 2 or PR 3 until the prior PR is reviewed and merged into dev.

Preserve:
- The approved Question Mark Home geometry
- The Sign Palette values
- iOS deployment target 18.0
- Current Swift language mode
- Demo and Firebase boundaries
- Public-safe repository rules
- Existing user work and local credentials

Do not:
- Commit to main
- Merge or publish
- Add dependencies
- Copy the full external asset package into the app target
- Create duplicate AppIcon assets
- Invent Xcode app-icon appearance schema
- Claim success without command output
- Add screenshots before current-build capture

At every checkpoint report:
Facts
Files changed
Commands run
Exact pass/fail results
Risks
Next task

Stop immediately on a failed baseline, checksum, asset compilation, build, test, secret scan, or demo validation gate.
```
