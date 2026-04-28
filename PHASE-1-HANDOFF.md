# Phase 1 Handoff

## Purpose

This document records what Phase 1 completed, what remains incomplete, and what future phases can safely build on.

Refer to `PROJECT-PLAN.md` for the full phased roadmap.

## Phase 1 Scope

Phase 1 focused on the domain model foundation. The goal was to expand `TrackerStore` so future dashboard, settings, history, analytics, menu bar, and alert work can reuse stable app state and derived metrics.

This phase intentionally avoided a full UI redesign.

## Files Changed

- `Sources/SitStandTracker/TrackerStore.swift`
- `Sources/SitStandTracker/ContentView.swift`
- `PROJECT-PLAN.md`

## Completed

### Domain Types Added

`TrackerStore.swift` now includes these model types:

- `UserPreferences`
- `GoalStatus`
- `TrackingState`
- `AlertKind`
- `AlertState`
- `SessionSource`

### Preferences

`UserPreferences` now models the MVP work-cycle settings:

- `targetStandingBlockMinutes`
- `targetSittingBlockMinutes`
- `defaultSnoozeMinutes`
- `hasCompletedInitialSetup`
- `lastUpdatedAt`

Default values are:

- stand: `15` minutes
- sit: `45` minutes
- snooze: `5` minutes

Preferences are persisted in `UserDefaults` under `sit-stand-preferences`.

### Target Ratio

The store now derives:

- target sitting share
- target standing share
- compact target ratio text

For the default settings, the ratio text is:

```text
1 stand / 3 sit
```

### Goal Status

`GoalStatus` supports:

- `Met`
- `Exceeded`
- `Not Met`
- `Insufficient Data`

The implemented rules match `DECISIONS.md`:

- days under `30` minutes of active tracked time are `Insufficient Data`
- `Met` uses a `+/- 5 percentage point` tolerance around target standing share
- above the tolerance band is `Exceeded`
- below the tolerance band is `Not Met`

### Session Metadata

`TrackingSession` now includes:

- `source`
- `createdAt`

`ActiveSession` now includes:

- `source`

The current manual flows use:

- `.manualStart` when starting from stopped
- the prior active session source when closing that active segment
- `.manualSwitch` when starting the new segment after a posture switch

### Backward Compatibility

`TrackingSession` and `ActiveSession` have custom decoding so older persisted `UserDefaults` data can still load.

Fallback behavior:

- missing completed-session `source` defaults to `.manualSwitch`
- missing completed-session `createdAt` defaults to `endDate`
- missing active-session `source` defaults to `.restoredAfterRelaunch`

### Store State

`TrackerStore` now persists:

- completed sessions
- active session
- preferences
- tracking state
- alert state

Storage keys currently used:

- `sit-stand-sessions`
- `sit-stand-active-session`
- `sit-stand-preferences`
- `sit-stand-tracking-state`
- `sit-stand-alert-state`

### Reset Behavior

`clearHistory()` now matches `DECISIONS.md`:

- clears completed sessions
- clears active session
- sets tracking state to `.stopped`
- clears alert state
- preserves preferences

### Derived Metrics

`TrackerStore.todaySummary` now derives:

- sitting duration
- standing duration
- average sit duration
- average stand duration
- longest sitting duration
- longest standing duration
- target sitting share
- target standing share
- goal status

The active session is included in today's totals and longest streak when it started today.

Completed sessions only are used for average sit and average stand.

### Minimal UI Exposure

`ContentView.swift` was lightly updated to show the new derived values without redesigning the app:

- target ratio in the hero card
- goal status in the Today section
- metric cards for:
  - Avg Sit
  - Avg Stand
  - Sit Streak
  - Stand Streak

## Verified

`swift build` passed after Phase 1 changes.

## Intentionally Left Incomplete

### Alert Engine

`AlertState` and `AlertKind` exist, but threshold evaluation is not implemented yet.

Still missing:

- checking thresholds during `tick()`
- entering alert states
- snooze action
- dismiss action
- rearm timing
- alert persistence semantics across relaunch

This belongs to Phase 6.

### Full Runtime State Machine

`TrackingState` exists and is updated for basic manual flows only.

Currently handled:

- stopped
- active sitting
- active standing

Still missing:

- setup
- locked sitting
- locked standing
- alert states
- snoozed states
- relaunch edge cases
- day-boundary transitions

These belong to Phases 6, 8, and 9.

### Preferences UI

Preferences are modeled and persisted, but there is no UI for editing them yet.

Still missing:

- Settings page controls
- dashboard goal-card editing
- validation feedback
- setup flow

This belongs to Phase 3.

### Sidebar And Multi-Page UI

The current UI is still the original single-page tracker with a few added metrics.

Still missing:

- Dashboard page shell
- History page
- Analytics page
- Settings page
- sidebar navigation

These belong to Phases 2 through 5.

### Menu Bar Extra

No menu bar app behavior has been implemented.

Still missing:

- `MenuBarExtra`
- compact timer label
- normal menu bar panel
- alert menu bar panel
- switch/stop actions from the menu bar

This belongs to Phase 7.

### Window Lifecycle

Close-to-menu-bar behavior is not implemented.

Still missing:

- closing window keeps app running
- reopening dashboard from menu bar
- explicit menu bar quit
- Dock icon hiding behavior
- quit-time persistence audit

This belongs to Phase 8.

### Screen Lock And Midnight Splitting

No screen-lock or day-boundary accounting has been implemented.

Still missing:

- screen lock observation
- closing active segment at lock time
- unlock resume in prior posture
- excluding locked time
- splitting sessions across midnight
- computing summaries for arbitrary day keys

This belongs to Phase 9.

### Tests

No test target exists yet, and no automated tests were added in Phase 1.

Future phases should consider adding a test target once domain behavior starts becoming harder to verify manually, especially for:

- goal status calculation
- preference persistence
- alert rearm behavior
- midnight splitting
- screen-lock suspend/resume

## Notes For Future Phases

### Phase 2

Phase 2 can use these existing store APIs immediately:

- `currentPosture`
- `elapsedInCurrentPosture`
- `todaySummary`
- `todaySessions`
- `targetRatioText`
- `start(posture:)`
- `stopTracking()`
- `clearHistory()`

The dashboard should not need to recalculate metrics locally.

### Phase 3

Phase 3 should build UI around:

- `preferences`
- `updatePreferences(targetStandingBlockMinutes:targetSittingBlockMinutes:defaultSnoozeMinutes:)`

The update method clamps values to at least `1` minute and persists immediately.

### Phase 4

History work will need a more general daily summary API.

The current implementation only exposes `todaySummary`. It has a private `summary(for:calendar:)` helper that could be made public/internal when History needs summaries for prior days.

### Phase 5

Analytics should use derived summaries rather than persisting analytics rows.

A likely next store API is:

```swift
func summariesForRecentDays(count: Int) -> [DaySummary]
```

That API should be added when Phase 5 begins.

### Phase 6

Alert implementation should reuse:

- `preferences.targetSittingBlockMinutes`
- `preferences.targetStandingBlockMinutes`
- `preferences.defaultSnoozeMinutes`
- `alertState`
- `trackingState`

Alerts should be cleared anywhere posture changes or tracking stops.

### Phase 9

Day-boundary splitting is not currently solved. Today's summary only includes an active session if the active session started today.

This means an active session that started before midnight will not currently contribute post-midnight time to today's total. Phase 9 should fix this by either:

- splitting sessions at midnight, or
- calculating active-session overlap with the requested day.

## Known Caveats

1. This directory is currently not a git repository, so normal `git diff` and `git status` were unavailable during Phase 1.
2. `PROJECT-PLAN.md` marks Phase 1 as completed, but the detailed handoff is in this file.
3. The docs still contain some stale path references from the prior directory structure; cleanup remains in Phase 10 unless it becomes blocking sooner.

