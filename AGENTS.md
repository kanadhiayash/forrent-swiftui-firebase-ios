# FourRent Agent Instructions

This repo follows the global Zeref OS instructions plus the local rules below.

## Branch Policy

- `main` is the default and final-review branch.
- `dev` is the integration branch.
- Do not merge feature work directly into `main`.
- Create short-lived branches from `dev` using `type/for-rent__short-scope`.
- Open implementation pull requests into `dev`.
- Open one final `dev` to `main` pull request for Yash's review before demo capture.
- Keep external repos and skill packs reference-only unless Yash explicitly approves vendoring, submodules, or copied code.

## Public-Safe Rules

- Keep For Rent positioned as a portfolio-grade SwiftUI Firebase prototype, not an App Store-ready or production rental marketplace.
- Do not add fake screenshots, fake demo media, fake metrics, fake deployments, or unverified claims.
- Do not print, commit, or summarize real secret values.
- `For Rent/Services/GoogleService-Info.plist` must remain local and untracked.
- Use `For Rent/Services/GoogleService-Info.example.plist` for public setup documentation.

## Skill Routing

When the user's request clearly matches an available workflow, use the matching skill or agent path. Main Codex owns final edits, source-of-truth decisions, and public-safe handling.

- Product strategy or scope review: use a product/CEO review lane.
- iOS architecture or SwiftUI refactor review: use an engineering review lane.
- Security, Firebase rules, secrets, or OWASP-style review: use a defensive security lane.
- QA, simulator checks, screenshots, or demo capture: use the iOS QA lane and gstack/browser tooling where applicable.
- Code diff or pre-merge review: use a code review lane.
- Documentation, README, release notes, and demo scripts: use a docs/release lane.

## Required Gates

Before opening or merging a PR, run the relevant checks and report exact pass/fail status:

- `git status`
- `npm run scan:secrets`
- `npm run validate:demo`
- `npm run test:firebase`
- `xcodebuild -list -project "For Rent.xcodeproj"`
- `xcodebuild build -project "For Rent.xcodeproj" -scheme "For Rent" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO`

If a command is not applicable to the change, state why. If a command fails, include the command, sanitized error, and next fix.
