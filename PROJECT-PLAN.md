# SitStandTracker Project Plan

## Purpose

This document turns the product specs into an implementation roadmap that can be picked up one slice at a time.

The existing docs remain the product source of truth:

- `SPEC.md` defines the overall MVP.
- `DATA-MODEL.md` defines the intended domain model.
- `STATE-MACHINE.md` defines runtime behavior.
- `STARTUP-UI.md`, `PAGE-SPECS.md`, `INTERACTIONS.md`, and `MENUBAR-ALERTS.md` define UI and interaction behavior.
- `DECISIONS.md` captures final product choices.

This plan focuses on implementation order, dependencies, and acceptance criteria.

## Current Baseline

The app currently has a working SwiftUI tracker with:

- one main window
- sitting and standing posture states
- one active session at a time
- manual posture switching
- stop tracking
- reset all data
- live elapsed timer
- today sitting and standing totals
- current-day completed session list
- `UserDefaults` persistence for completed sessions and active session

The main implementation files are:

- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- `Sources/SitStandTracker/ContentView.swift`
- `Sources/SitStandTracker/TrackerStore.swift`

The current app does not yet implement:

- sidebar navigation
- dashboard/history/analytics/settings pages
- work-cycle preferences
- goal status
- menu bar extra
- alert/snooze/dismiss lifecycle
- screen-lock suspend/resume
- day-boundary session splitting
- close-to-menu-bar behavior

## Guiding Implementation Principles

1. Keep `TrackerStore` as the single domain state owner until there is enough complexity to split it.
2. Add model types before adding UI that depends on them.
3. Prefer derived summaries over persisted summaries.
4. Keep completed sessions immutable.
5. Preserve working tracking behavior at every milestone.
6. Build the main-window MVP before menu-bar lifecycle work.
7. Make every phase buildable with `swift build`.

## Phase 1: Domain Model Foundation

Status: Completed on 2026-04-28. See `PHASE-1-HANDOFF.md` for details on what was implemented and what remains incomplete.

Goal: expand the current simple model so later dashboard, alert, and history features have stable state to use.

Likely files:

- `Sources/SitStandTracker/TrackerStore.swift`

Tasks:

1. Add `UserPreferences`.
2. Add `GoalStatus`.
3. Add `TrackingState`.
4. Add `AlertKind` and `AlertState` as dormant model types.
5. Add `SessionSource`.
6. Extend `TrackingSession` with `source` and `createdAt`.
7. Add compatibility decoding or a migration path for existing stored sessions.
8. Add derived properties for:
   - target sitting share
   - target standing share
   - daily goal status
   - average sit duration
   - average stand duration
   - longest sitting streak
   - longest standing streak

Acceptance criteria:

- Existing start, switch, stop, reset, and restore behavior still works.
- Preferences persist independently from session history.
- Reset data preserves preferences, matching `DECISIONS.md`.
- `swift build` passes.

Notes:

- A low-data day under 30 minutes should produce `Insufficient Data` rather than `Met`, `Exceeded`, or `Not Met`.
- Goal status tolerance is `+/- 5 percentage points`.

## Phase 2: Dashboard Shell

Status: Completed on 2026-04-28. See `PHASE-2-HANDOFF.md` for details on what was implemented and what remains incomplete.

Goal: replace the simple one-page UI with the startup dashboard described in `STARTUP-UI.md`.

Likely files:

- `Sources/SitStandTracker/ContentView.swift`

Tasks:

1. Add sidebar navigation with:
   - Dashboard
   - History
   - Analytics
   - Settings
2. Build the dashboard layout:
   - left navigation rail
   - current status card
   - daily goal card
   - metrics row
   - recent activity panel
3. Keep posture actions available:
   - start sitting
   - start standing
   - switch to opposite posture
   - stop tracking
4. Show derived metrics:
   - Avg Sit
   - Avg Stand
   - Sit Streak
   - Stand Streak
5. Show target ratio text derived from preferences.

Acceptance criteria:

- Dashboard is the launch view.
- Timer updates once per second.
- The primary action reflects the current state.
- Recent activity shows newest completed sessions first.
- The app still works well at the current minimum window size.
- `swift build` passes.

## Phase 3: Settings And Preferences Editing

Status: Completed on 2026-04-28. See `PHASE-3-HANDOFF.md` for details on what was implemented and what remains incomplete.

Goal: let the user edit the work-cycle pair that drives ratios and later alerts.

Likely files:

- `Sources/SitStandTracker/ContentView.swift`
- `Sources/SitStandTracker/TrackerStore.swift`

Tasks:

1. Build the Settings page.
2. Add controls for:
   - stand duration
   - sit duration
   - default snooze duration
   - reset data
3. Add lightweight editing controls to the dashboard goal card.
4. Validate preference values.
5. Persist preference changes immediately.

Acceptance criteria:

- Updating stand/sit durations changes the target ratio everywhere.
- Invalid or zero durations cannot be saved.
- Reset data clears history/runtime state but preserves preferences.
- `swift build` passes.

## Phase 4: History Page

Status: Completed on 2026-04-28. See `PHASE-4-HANDOFF.md` for details on what was implemented and what remains incomplete.

Goal: add day-grouped local history with goal status.

Likely files:

- `Sources/SitStandTracker/ContentView.swift`
- `Sources/SitStandTracker/TrackerStore.swift`

Tasks:

1. Add day grouping for completed sessions.
2. Build newest-first history cards.
3. Show per-day:
   - date
   - sitting total
   - standing total
   - standing share
   - goal status badge
4. Add inline expansion to show sessions for a day.
5. Include active current-day time in today's summary where appropriate.

Acceptance criteria:

- Today appears as the default/top history day.
- Prior days can be browsed locally.
- Status badges use text plus visual treatment.
- Low-data days show `Insufficient Data`.
- `swift build` passes.

## Phase 5: Analytics Page

Goal: add a narrow, useful analytics view for recent ratio behavior.

Likely files:

- `Sources/SitStandTracker/ContentView.swift`
- `Sources/SitStandTracker/TrackerStore.swift`

Tasks:

1. Build a 7-day analytics page.
2. Add a simple stacked bar visualization for sit/stand time.
3. Show counts for:
   - Met
   - Exceeded
   - Not Met
   - Insufficient Data
4. Show:
   - average active tracked time
   - average sit session length
   - average stand session length

Acceptance criteria:

- Analytics use derived session data only.
- The default range is 7 days with no range switcher.
- Empty/low-data states are clear.
- `swift build` passes.

## Phase 6: Alert State Engine

Goal: implement threshold evaluation without menu-bar UI first.

Likely files:

- `Sources/SitStandTracker/TrackerStore.swift`

Tasks:

1. Evaluate alert thresholds during `tick()`.
2. Enter `time_to_stand` after sitting threshold is reached.
3. Enter `time_to_sit` after standing threshold is reached.
4. Add snooze behavior.
5. Add dismiss behavior.
6. Clear alerts on posture switch and stop tracking.
7. Persist alert state.

Acceptance criteria:

- Alerts do not stack.
- Snooze and dismiss both rearm after `defaultSnoozeMinutes`.
- Switching posture clears alert/snooze state.
- Stopping tracking clears alert/snooze state.
- `swift build` passes.

## Phase 7: Menu Bar Extra

Goal: add the persistent menu bar companion.

Likely files:

- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- `Sources/SitStandTracker/ContentView.swift`
- possibly new SwiftUI view files

Tasks:

1. Add `MenuBarExtra`.
2. Show posture icon plus compact elapsed time.
3. Build normal menu bar panel:
   - current posture
   - active-session label
   - large timer
   - target ratio
   - switch action
   - stop tracking
   - today's current-posture total
   - longest streak
4. Build alert menu bar panel:
   - alert title
   - large timer
   - transition explanation
   - primary switch action
   - snooze
   - dismiss
   - today totals
5. Make alert states visually distinct by more than color.

Acceptance criteria:

- Menu bar item exists while app runs.
- User can switch posture from menu bar.
- User can stop tracking from menu bar.
- Alert and normal panels show the correct controls.
- `swift build` passes.

## Phase 8: Window And App Lifecycle

Goal: make the app behave like a hybrid dashboard plus menu-bar utility.

Likely files:

- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- possibly an app delegate or scene coordinator

Tasks:

1. Closing the main window keeps the app running.
2. Closing the main window keeps tracking active.
3. Reopen dashboard from the menu bar.
4. Add explicit quit from the menu bar.
5. Persist state before quit.
6. Consider Dock icon hiding after window close.

Acceptance criteria:

- Closing the dashboard does not stop tracking.
- Menu bar can reopen the dashboard.
- Quit removes the menu bar item by ending the app.
- Same-day relaunch restores active/stopped state.
- `swift build` passes.

## Phase 9: Screen Lock And Day Boundary Rules

Goal: implement the lifecycle rules that make time accounting accurate.

Likely files:

- `Sources/SitStandTracker/TrackerStore.swift`
- possibly app lifecycle notification wiring

Tasks:

1. Observe screen lock.
2. Close active session at lock time.
3. Enter locked posture state.
4. Observe screen unlock.
5. Resume same posture in a new session.
6. Exclude locked time from totals, ratios, streaks, and alerts.
7. Split active sessions across midnight.
8. Ensure summaries compute by local day key.

Acceptance criteria:

- Locked time never counts toward tracked time.
- Unlock resumes the prior posture.
- Midnight does not reset current posture.
- Daily reporting correctly separates sessions by day.
- `swift build` passes.

## Phase 10: Polish And Verification

Goal: tighten UX, docs, and maintainability after feature completion.

Tasks:

1. Update `README.md` for the new directory structure.
2. Replace stale absolute mockup links with relative paths.
3. Add focused unit tests if the package structure is expanded to support tests.
4. Review accessibility labels for icon-only controls.
5. Review window sizing and responsive behavior.
6. Run `swift build`.
7. Run the app manually and verify core flows.

Acceptance criteria:

- Documentation matches the current repo location.
- All major controls are discoverable and accessible.
- Manual smoke test covers start, switch, stop, reset, relaunch, menu bar, alert, and settings flows.

## Suggested First Implementation Slice

Start with Phase 1.

The best first task is:

> Add `UserPreferences`, derived ratio metrics, and goal status to `TrackerStore` while preserving the current UI.

Why this first:

- It has low UI risk.
- It unlocks dashboard, settings, history, analytics, and alerts.
- It makes the next UI work mostly a presentation layer over stable derived data.

Suggested first-task checklist:

1. Add preference model with defaults:
   - stand `15` minutes
   - sit `45` minutes
   - snooze `5` minutes
2. Persist preferences in `UserDefaults`.
3. Add derived target ratio text.
4. Add daily metric helpers.
5. Add goal status, including insufficient-data behavior.
6. Keep current `ContentView` compiling with minimal changes.
7. Run `swift build`.
