# Zeref OS Local Setup

For Rent uses an optional local Zeref OS clone for private, cross-session
continuity. The clone is not committed to this repository.

## Tested Version

- Repository: `https://github.com/kanadhiayash/zeref-os`
- Tested commit: `c926c34668be20adf77553a4dfecc71cef02951f`
- Local path: `.zeref/`

## Install

```bash
git clone https://github.com/kanadhiayash/zeref-os.git .zeref
git -C .zeref checkout c926c34668be20adf77553a4dfecc71cef02951f
```

Then update `.zeref/config/PROJECT.md` for For Rent:

- `project_name: "For Rent"`
- `project_root: "."`
- `privacy_mode: abstract`
- `parent_project: null`

The bundled `PRIVACY.md` and `REDACT.md` keep credentials, personal data, and
absolute local paths out of memory. `SHARING_POLICY.md` leaves every connector
disabled by default. Parent sync remains disabled.

## Operating Rules

- Treat `.zeref/AGENTS.md` as the local Zeref source of truth.
- Do not copy Zeref OS repository history into For Rent memory.
- Do not enable connectors, external sync, or parent push without explicit
  approval.
- Never store Firebase configuration values, demo-persona contact details, or
  private property addresses in Zeref memory.
