# Product

## Users

For Rent serves three user contexts:

- Renters currently browse listings, compare property details, save properties, submit rental requests, and track request decisions.
- Landlords currently publish and manage listings, review renter contact details, and accept or reject rental requests.
- Guests browse public listings and property details before signing in for protected actions.

Planned product direction includes commercial and temporary-stay categories, viewing coordination, messaging, booking details, availability calendars, ratings, and reviews. These planned capabilities are not part of the current build.

The primary product context is mobile rental discovery and coordination in Canadian markets. Location-specific launch scope is still to be defined.

## Product Purpose

For Rent is a SwiftUI rental marketplace that connects property discovery, saved listings, rental requests, and landlord decisions in one role-aware app. The product should demonstrate senior product-design judgment, practical iOS engineering, and secure Firebase data ownership without overstating production readiness.

Success means each user can understand their next action, complete the current request workflow without hidden state, and trust that account, listing, shortlist, and request data is handled according to their role.

## Brand Personality

Trustworthy, composed, and human.

The experience should feel polished and familiar without copying Airbnb's visual identity. Copy is direct, calm, and useful. The interface should feel designed for real repeated use, not for a marketing screenshot.

## Anti-references

- Generic AI-generated dashboards, decorative gradients, glass cards, oversized headings, and repeated card grids.
- Airbnb branding, icons, copy, or layout copied closely enough to create confusion.
- Prototype-only UI that exposes raw coordinates, technical IDs, or database state to users.
- Dark patterns, surprise permissions, hidden booking rules, or color-only status communication.
- Public claims that the app is App Store-ready, shipped, or production-secure before those gates are verified.

## Design Principles

1. Make role and state obvious. Users should always know whether they are browsing, requesting, reviewing, messaging, or confirming.
2. Put trust before conversion. Surface identity, ratings, policies, availability, and validation before asking users to commit.
3. Keep one clear next action per screen. Secondary actions should remain available without competing with the primary task.
4. Use familiar iOS behavior. Prefer native SwiftUI navigation, controls, sheets, alerts, and accessibility behavior.
5. Show honest system status. Loading, empty, error, success, unavailable,
   submitted, acknowledged, viewing, accepted, rejected, cancelled, and expired
   states must be explicit.

## Accessibility & Inclusion

- Target WCAG 2.2 AA contrast for text and controls.
- Support Dynamic Type without clipped labels or broken layouts.
- Provide VoiceOver labels and logical reading order for interactive surfaces.
- Never rely on color alone for status.
- Respect Reduce Motion and avoid decorative animation.
- Keep tap targets at least 44 by 44 points.
- Use plain language for errors, permissions, booking rules, and destructive actions.
