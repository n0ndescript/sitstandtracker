# Phase 3 Handoff

## Purpose

This document records what Phase 3 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap, `PHASE-1-HANDOFF.md` for the domain model foundation, and `PHASE-2-HANDOFF.md` for the dashboard shell.

## Phase 3 Scope

Phase 3 made the work-cycle preferences editable in the main window.

The focus was preference editing and persistence. This phase did not implement setup flow, alerts, menu bar behavior, multi-day history, or 7-day analytics.

## Files Changed

- `Sources/SitStandTracker/ContentView.swift`
- `PROJECT-PLAN.md`

## Completed

### Dashboard Goal Editing

The Daily Goal card now includes compact steppers for:

- stand duration
- sit duration

Changing either value updates the derived target ratio immediately.

### Settings Editing

The Settings page now includes steppers for:

- `Stand for`
- `After sitting for`
- `Default snooze`

The page also displays the derived target ratio.

### Persistence

All preference controls call:

```swift
trackerStore.updatePreferences(
    targetStandingBlockMinutes:targetSittingBlockMinutes:defaultSnoozeMinutes:
)
```

That store method persists immediately to `UserDefaults`.

### Validation

The UI constrains values before they reach the store:

- stand duration: `1...240` minutes
- sit duration: `1...240` minutes
- snooze duration: `1...60` minutes

The store also clamps values to a minimum of `1` minute.

### Reset Behavior

The existing reset action still calls `trackerStore.clearHistory()`.

Per Phase 1 behavior, reset clears:

- completed sessions
- active session
- tracking state
- alert state

It preserves:

- stand duration
- sit duration
- snooze duration

## Verified

`swift build` passed after Phase 3 changes.

## Intentionally Left Incomplete

### First-Run Setup Flow

Preferences can now be edited, but there is still no first-run setup experience.

Still missing:

- detecting incomplete setup as a UI state
- asking for work-cycle values on first launch
- transitioning from setup to active tracking

This should be considered alongside later lifecycle work.

### Inline Validation Messages

The controls constrain values, so invalid values cannot be selected from the UI.

Still missing:

- visible validation messages
- typed numeric fields
- handling non-stepper input

These are not necessary for the current MVP unless the UI changes from steppers to text fields.

### Alert Engine

The editable durations are now available, but no alert engine reads them yet.

Still missing:

- threshold evaluation during `tick()`
- alert state transitions
- snooze and dismiss actions

This belongs to Phase 6.

### Menu Bar

The menu bar panel should eventually reuse the editable preferences for target-ratio text and alert thresholds.

This remains in Phase 7.

## Notes For Future Phases

### Phase 4

History can assume preferences are user-editable and persisted.

If day-level history needs historically accurate target ratios, the data model may eventually need to store preference snapshots per day. The current MVP evaluates summaries against the current preference values.

### Phase 5

Analytics should use the current preference target ratio unless historical preference snapshots are added.

### Phase 6

Alert thresholds should read:

- `trackerStore.preferences.targetSittingBlockMinutes`
- `trackerStore.preferences.targetStandingBlockMinutes`
- `trackerStore.preferences.defaultSnoozeMinutes`

Changing preferences while tracking is active should affect future threshold evaluation immediately.

