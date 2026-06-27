# GitHub Protection Configuration

These settings must be applied in the GitHub repository after this branch is
reviewed. They are documented here because changing remote rulesets requires
explicit owner approval.

## Main branch

Create a ruleset targeting `main` with:

- Require a pull request before merging.
- Require at least one approving review.
- Dismiss stale approvals when new commits are pushed.
- Require review from Code Owners.
- Require conversation resolution.
- Require branches to be up to date.
- Require linear history.
- Block force pushes.
- Block branch deletion.
- Require these exact checks:
  - `build-ios-simulator`
  - `unit-tests`
  - `ui-smoke-tests`
  - `firebase-emulator-tests`
  - `secrets-hygiene`
  - `demo-fixture-validation`

## Release tags

Create a second ruleset targeting `v*` tags:

- Restrict tag creation and updates to repository maintainers.
- Block force updates and deletion.

## Release gate

Do not create `v1.1.0` until the reviewed pull request is merged, every required
check is green, Firebase rules have passed against the emulator, and real
release screenshots are attached. This repository does not automate publishing
or remote Firebase deployment.
