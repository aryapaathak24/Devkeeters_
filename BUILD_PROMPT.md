# Build Prompt — Quick-Commerce Companion App

Paste this as the system/project prompt for an AI coding agent (Claude Code, Cursor, etc.)
at the start of a fresh session for this project.

---

## ⚠️ Context Override — Read First

This is a **new, standalone project.** It is not AATCe Connect and does not extend it.

If you (the agent) have access to any prior context, memory, or handoff docs from AATCe
Connect (`PROJECT_STATUS.md`, `HANDOFF.md`, its 5-role permission system, its Firestore
schema) — **do not carry any of that over.** Specifically:

- New Firebase project. No shared Auth, Firestore, or Storage with AATCe Connect.
- New repo. No shared code, even if a pattern (e.g. shared-cart-via-listener) looks similar
  to something built there — re-implement it fresh for this project's schema.
- New roles/permissions model. This app's "household member" concept is unrelated to AATCe
  Connect's aviation-training roles. Don't reuse role names, gates, or approval logic.
- The *only* thing carried over on purpose is engineering judgment: patterns that worked
  there (real-time listener + membership doc for shared state) are reused as **patterns**,
  not as literal shared infrastructure.

If you're ever unsure whether something belongs to this project or the other one, stop and
ask rather than assuming.

---

## Project Overview

A quick-commerce companion app, SwiftUI + Firebase, built solo. Seven feature concepts,
tiered by build difficulty — see `Quick_Commerce_App_Spec.docx` for the full spec and
`/flows/*.json` for exact screen-by-screen states and user flows per feature.

**Tiers:**
- **Tier A** (build first — no external data dependency): Night Emergency Mode, Crew Mode,
  Menu Advisor (consumer combo-value flag)
- **Tier B** (real algorithm/pipeline, core differentiation): Predicting Baskets, Smart
  Reading, Group Social Ordering
- **Tier C** (depends on data outside our control — scope narrow, expect ongoing
  maintenance, not one-and-done): PantryLens fridge-photo detection, Deal & Price Radar,
  Menu Advisor vendor-pricing dashboard

## Tech Stack

- Client: SwiftUI, MVVM
- Auth: Firebase Auth
- Database: Firestore (real-time listeners for Crew Mode / Group Ordering)
- Backend: Cloud Functions (TypeScript) for scheduled jobs, OCR/parsing pipelines
- Storage: Firebase Storage (pantry/receipt photos)
- OCR: Apple Vision framework on-device for receipts; Cloud Vision API only if fridge-photo
  detection needs it later
- Notifications: Firebase Cloud Messaging
- Scheduling: Cloud Scheduler + Pub/Sub
- Payments: Razorpay (Group Ordering bill splits)

Full Firestore schema is in the spec doc, Section 5.

## Ground Rules

1. **Ask before building new features.** If something isn't in the spec or the flow JSON
   files, propose it and wait — don't build ahead of scope.
2. **Follow tier order.** Don't start a Tier C feature before the corresponding Tier A/B
   work for that feature area is stable. If asked to jump ahead, flag the risk first.
3. **Heuristics before ML.** Predicting Baskets is an interval-averaging calculation. Don't
   reach for a trained model unless the simple version demonstrably fails.
4. **Flag external-data dependencies before starting them.** Deal & Price Radar and the
   vendor Menu Advisor both need data sources we don't have yet (scraping, competitor
   pricing). Confirm the data source is real and workable before writing product code
   against it.
5. **Reference the flow JSON before building any screen.** Each file in `/flows` defines
   the screens, states (loading/empty/success/error), primary actions, and transitions for
   one feature. Implement to that spec, don't improvise new states or skip error/empty
   states.
6. **One phase at a time.** Confirm a phase is actually done (matches its flow JSON,
   handles its edge cases) before starting the next. Don't let phases blur together.

## Phase Checklist

- [ ] **Phase 0 — Foundation:** Auth, base vendor/catalog model, basic cart & checkout
- [ ] **Phase 1 — Tier A:** Night Emergency Mode, Menu Advisor (consumer)
- [ ] **Phase 2 — Tier B core:** Predicting Baskets, Crew Mode
- [ ] **Phase 3 — Tier B camera:** Smart Reading (receipt OCR)
- [ ] **Phase 4 — Tier B social:** Group Social Ordering
- [ ] **Phase 5 — Tier C experiments:** Deal & Price Radar (single-URL), PantryLens
      fridge-photo, vendor Menu Advisor dashboard

## Definition of Done (per feature)

A feature is done when: every screen in its flow JSON exists, every listed state
(loading/empty/success/error) is handled — not just the happy path — and every edge case
in the JSON's `edgeCases` array has been considered, even if the resolution is "explicitly
out of scope for v1."

## Files in This Package

- `Quick_Commerce_App_Spec.docx` — full product & technical spec
- `flows/01_pantrylens.json` through `flows/07_menu_pricing_advisor.json` — per-feature
  screen states, transitions, user flow, and edge cases
- `BUILD_PROMPT.md` — this file
