# Phase 6 Handoff

## Purpose

This document records what Phase 6 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and the prior phase handoff files for earlier implementation context.

## Phase 6 Scope

Phase 6 implemented the alert state engine.

The focus was threshold evaluation, alert state transitions, snooze, dismiss, clearing rules, and persistence. A small in-window alert panel was added so the behavior can be exercised before the menu bar UI is built.

This phase did not implement the final menu bar alert UI, system notifications, screen-lock behavior, or midnight splitting.

## Files Changed

- `Sources/SitStandTracker/TrackerStore.swift`
- `Sources/SitStandTracker/ContentView.swift`
- `PROJECT-PLAN.md`

## Completed

### Alert Metadata

`AlertKind` now exposes:

- `title`
- `recommendedPosture`
- `activePosture`

This lets UI surfaces ask the alert what action it represents without duplicating the sit/stand mapping.

### Active Alert Accessors

`TrackerStore` now exposes:

```swift
var activeAlertKind: AlertKind?
var isAlertSnoozed: Bool
```

`activeAlertKind` is non-nil only when the alert is currently visible.

`isAlertSnoozed` is true while a future `snoozeUntil` exists.

### Threshold Evaluation

`tick()` now:

1. updates `now`
2. evaluates alert state

Alert thresholds come from preferences:

- sitting threshold: `preferences.targetSittingBlockMinutes`
- standing threshold: `preferences.targetStandingBlockMinutes`

When the current posture exceeds its threshold:

- sitting enters `time_to_stand`
- standing enters `time_to_sit`

The matching `trackingState` becomes:

- `.alertTimeToStand`
- `.alertTimeToSit`

### Snooze

`TrackerStore.snoozeAlert()`:

- keeps the active session running
- hides the alert surface
- sets `snoozeUntil`
- keeps `currentAlertKind`
- enters the matching snoozed tracking state

Snooze duration uses:

```swift
preferences.defaultSnoozeMinutes
```

### Dismiss

`TrackerStore.dismissAlert()`:

- behaves like snooze for timing
- records `lastDismissedAt`
- keeps the active session running

This matches the MVP rule that dismiss and snooze both rearm after the snooze interval.

### Primary Alert Action

`TrackerStore.switchToAlertRecommendation()` switches to the posture recommended by the active alert.

This uses existing posture-switch behavior, so it:

- closes the current active session
- starts the opposite posture
- clears alert state
- clears snooze state

### Clearing Rules

Alert state is cleared when:

- posture changes
- tracking stops
- history/runtime state is reset
- there is no active session
- the active posture no longer matches the stored alert kind
- the active session is below the relevant threshold after preference changes

### Preference Changes

`updatePreferences(...)` now evaluates alerts before persisting.

This means lowering a threshold can surface an alert quickly, and raising a threshold can clear an alert if the current active session is no longer overdue.

### Persistence

Alert state continues to persist through the existing `alertState` blob in `UserDefaults`.

On load, the store evaluates alert state using the restored active session and current time.

This supports restoring an overdue alert or expired snooze after relaunch.

### In-Window Alert Surface

`ContentView` now shows a compact alert panel in the current status card when `activeAlertKind` is visible.

The panel includes:

- alert title
- alert symbol
- elapsed active posture time
- primary switch action
- snooze button
- dismiss button

When an alert is snoozed, the current status card shows the snooze-until time.

This is a temporary verification surface. The final alert surface belongs to the menu bar in Phase 7.

## Verified

`swift build` passed after Phase 6 changes.

## Intentionally Left Incomplete

### Menu Bar Alert UI

The final alert presentation is not implemented yet.

Still missing:

- alert-state menu bar icon treatment
- normal menu bar panel
- alert menu bar panel
- menu bar switch/snooze/dismiss actions

This belongs to Phase 7.

### Screen Lock

Screen lock does not yet clear alert/snooze state or close active sessions.

This remains in Phase 9.

### Midnight Behavior

Crossing midnight does not yet split active sessions or completed sessions.

Alert eligibility still follows the continuous active session start time, which is acceptable for alert timing, but reporting still needs Phase 9 fixes.

### Alert Source Metadata

`switchToAlertRecommendation()` reuses the existing posture-switch path.

The new active session is not yet marked with `SessionSource.alertSwitch`.

If source-level analytics become important, the posture-switch implementation should accept an explicit source.

### Automated Tests

No test target exists yet.

The alert engine would benefit from tests for:

- threshold entry
- snooze rearm
- dismiss rearm
- preference changes while active
- posture switch clearing alert state
- stop tracking clearing alert state

## Notes For Future Phases

### Phase 7

Phase 7 should reuse:

- `trackerStore.activeAlertKind`
- `trackerStore.alertState`
- `trackerStore.switchToAlertRecommendation()`
- `trackerStore.snoozeAlert()`
- `trackerStore.dismissAlert()`

The in-window alert surface can remain as a dashboard companion, but the menu bar should become the primary intervention surface.

### Phase 9

When screen-lock behavior is added, lock handling should:

- close the active session at lock time
- clear alert state
- clear snooze state
- enter locked posture state

Unlock should start a fresh session in the prior posture and should not immediately restore the old alert.

