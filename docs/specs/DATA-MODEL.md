# SitStandTracker Data Model

## 1. Purpose

This document defines the canonical data model for SitStandTracker. It covers runtime state, persisted storage, alerts, goal evaluation, and dashboard metrics.

The model is designed to support:

- same-day restore after quit/relaunch
- menu bar tracking and alert behavior
- day-boundary session splitting
- ratio-based daily goal evaluation
- a lightweight local-first MVP

## 2. Modeling Principles

1. Persist raw posture sessions and enough runtime state to restore behavior.
2. Derive dashboard metrics from sessions whenever possible.
3. Split posture time at the day boundary for reporting accuracy.
4. Derive the daily goal from one work-cycle pair, not from a fixed duration target.
5. Treat UI state and tracking state as different concerns.

## 3. Core Entities

The MVP data model should include:

1. `UserPreferences`
2. `TrackingSession`
3. `RuntimeState`
4. `AlertState`
5. `DailySummary`

## 4. Enums

### 4.1 `Posture`

Allowed values:

- `sitting`
- `standing`

Notes:

- `stopped` is not a posture

### 4.2 `TrackingState`

Allowed values:

- `setup`
- `active_sitting`
- `active_standing`
- `locked_sitting`
- `locked_standing`
- `alert_time_to_stand`
- `alert_time_to_sit`
- `snoozed_sitting`
- `snoozed_standing`
- `stopped`

### 4.3 `WindowState`

Allowed values:

- `visible`
- `hidden_to_menubar`
- `quit`

Semantics:

- `hidden_to_menubar`
  - app is still running in the menu bar and hidden from the Dock

### 4.4 `AlertKind`

Allowed values:

- `time_to_stand`
- `time_to_sit`

### 4.5 `GoalStatus`

Allowed values:

- `met`
- `exceeded`
- `not_met`

## 5. UserPreferences

`UserPreferences` stores durable settings that persist across days.

### Fields

- `targetStandingBlockMinutes: Int`
- `targetSittingBlockMinutes: Int`
- `defaultSnoozeMinutes: Int`
- `hasCompletedInitialSetup: Bool`
- `lastUpdatedAt: Date`

### Semantics

- `targetSittingBlockMinutes`
  - after this many minutes of sitting, prompt `time_to_stand`
- `targetStandingBlockMinutes`
  - after this many minutes of standing, prompt `time_to_sit`
- `defaultSnoozeMinutes`
  - fixed to `5` in MVP, but modeled explicitly for future flexibility
- `hasCompletedInitialSetup`
  - determines whether setup is needed on launch when no data exists for the day

### Derived Goal Semantics

The app does not use a fixed standing-minutes-per-day goal.

Instead, the app derives a target active-time ratio from the work-cycle pair:

- target sitting share = `targetSittingBlockMinutes / (targetSittingBlockMinutes + targetStandingBlockMinutes)`
- target standing share = `targetStandingBlockMinutes / (targetSittingBlockMinutes + targetStandingBlockMinutes)`

Example:

- stand `15`
- sit `45`
- target ratio = `1:3 stand/sit`
- target standing share = `25%`

## 6. TrackingSession

`TrackingSession` is the fundamental history record.

Each record represents one continuous period of a single posture.

### Fields

- `id: UUID`
- `posture: Posture`
- `startAt: Date`
- `endAt: Date`
- `source: SessionSource`
- `createdAt: Date`

### 6.1 `SessionSource`

Allowed values:

- `initial_default`
- `manual_start`
- `manual_switch`
- `resume_after_unlock`
- `alert_switch`
- `restored_after_relaunch`
- `midnight_split_continuation`

### Semantics

- `startAt` is inclusive
- `endAt` is exclusive for reporting purposes
- `endAt` must be later than `startAt`
- sessions are immutable once completed
- each session belongs to exactly one posture

### Midnight Split Rule

If a posture spans midnight:

- close the prior session segment at midnight
- create a new session segment at midnight for the same posture

Example:

- sitting from `11:40 PM` to `12:20 AM`
- stored as:
  - session A: `11:40 PM` to `12:00 AM`
  - session B: `12:00 AM` to `12:20 AM`

This keeps each persisted session attributable to one calendar day.

## 7. RuntimeState

`RuntimeState` stores the minimum state needed to resume app behavior after quit/relaunch.

### Fields

- `trackingState: TrackingState`
- `windowState: WindowState`
- `activePosture: Posture?`
- `activeSessionStartedAt: Date?`
- `currentDayKey: String`
- `lastRestoredAt: Date?`

### Semantics

- `activePosture` is set only when tracking is active, alerting, snoozed, or locked
- `activeSessionStartedAt` refers to the current in-progress posture segment
- `currentDayKey` should use local calendar format such as `YYYY-MM-DD`

## 8. AlertState

`AlertState` stores the current alert and snooze lifecycle.

### Fields

- `currentAlertKind: AlertKind?`
- `alertTriggeredAt: Date?`
- `snoozeUntil: Date?`
- `lastDismissedAt: Date?`
- `isAlertVisible: Bool`

### Semantics

- `currentAlertKind` is non-nil only during alert or snoozed flows
- `alertTriggeredAt`
  - timestamp when the current threshold condition first entered alert state
- `snoozeUntil`
  - next time the alert may rearm
- `lastDismissedAt`
  - records the most recent dismiss action for behavior/debugging
- `isAlertVisible`
  - whether the alert presentation is currently open in the menu bar interaction

### MVP Dismiss Rule

For MVP:

- `dismiss` and `snooze` both postpone re-alerting by `defaultSnoozeMinutes`
- the difference is user intent and panel labeling, not timing

## 9. DailySummary

`DailySummary` is a derived view model for a single day.

It should not be the primary source of truth in MVP. It can be computed from sessions plus the active runtime state.

### Fields

- `dayKey: String`
- `sittingMinutes: Int`
- `standingMinutes: Int`
- `averageSitMinutes: Int`
- `averageStandMinutes: Int`
- `longestSittingStreakMinutes: Int`
- `longestStandingStreakMinutes: Int`
- `targetSittingShare: Double`
- `targetStandingShare: Double`
- `actualSittingShare: Double`
- `actualStandingShare: Double`
- `goalStatus: GoalStatus`

### Semantics

- `averageSitMinutes`
  - average duration of completed sitting sessions for that day
- `averageStandMinutes`
  - average duration of completed standing sessions for that day
- `longestSittingStreakMinutes`
  - longest single sitting segment for that day
- `longestStandingStreakMinutes`
  - longest single standing segment for that day
- `targetSittingShare`
  - derived from the configured cycle pair
- `targetStandingShare`
  - derived from the configured cycle pair
- `actualSittingShare`
  - sitting minutes divided by active tracked minutes
- `actualStandingShare`
  - standing minutes divided by active tracked minutes
- `goalStatus`
  - derived daily status based on actual ratio against target ratio

## 10. RecentActivityItem

`RecentActivityItem` is a UI-facing projection of session data for the dashboard list.

### Fields

- `sessionId: UUID`
- `posture: Posture`
- `startAt: Date`
- `endAt: Date`
- `durationMinutes: Int`

## 11. Relationships

### 11.1 Preferences To Runtime

- one `UserPreferences`
- one `RuntimeState`
- one `AlertState`

### 11.2 Sessions

- many `TrackingSession`
- active in-progress tracking is represented by `RuntimeState`, not by a completed session row

### 11.3 Daily Summary

- `DailySummary` is derived from:
  - sessions for `dayKey`
  - active runtime state if the active posture belongs to the same day
  - user preferences

## 12. Derived Metric Rules

### 12.1 Sitting Total

- sum all sitting session durations for the day
- add current active sitting duration if user is actively sitting on that day

### 12.2 Standing Total

- sum all standing session durations for the day
- add current active standing duration if user is actively standing on that day

### 12.3 Average Sit

- average of completed sitting session durations for the day
- do not include active in-progress sitting session in MVP

### 12.4 Average Stand

- average of completed standing session durations for the day
- do not include active in-progress standing session in MVP

### 12.5 Longest Sitting Streak

- longest single sitting segment in the current day
- a segment ends when posture changes, stop occurs, screen lock occurs, or midnight split occurs
- active current sitting segment may count if it is the longest so far

### 12.6 Longest Standing Streak

- longest single standing segment in the current day
- a segment ends when posture changes, stop occurs, screen lock occurs, or midnight split occurs
- active current standing segment may count if it is the longest so far

### 12.7 Goal Status

The app evaluates daily goal success from active tracked ratio, not fixed duration.

For MVP:

- target standing share is derived from the configured cycle pair
- actual standing share is derived from the day’s active tracked minutes
- use a tolerance band of `+/- 5 percentage points`

Then:

- `met`
  - actual standing share is within the tolerance band of target standing share
- `exceeded`
  - actual standing share is above the tolerance band
- `not_met`
  - actual standing share is below the tolerance band

## 13. Persistence Shape

For MVP using `UserDefaults`, persist these top-level blobs:

- `userPreferences`
- `runtimeState`
- `alertState`
- `trackingSessions`

Each blob should be Codable and versionable.

## 14. Suggested Codable Shapes

These are conceptual Swift shapes, not final code.

```swift
struct UserPreferences: Codable {
    var targetStandingBlockMinutes: Int
    var targetSittingBlockMinutes: Int
    var defaultSnoozeMinutes: Int
    var hasCompletedInitialSetup: Bool
    var lastUpdatedAt: Date
}

struct TrackingSession: Codable, Identifiable {
    var id: UUID
    var posture: Posture
    var startAt: Date
    var endAt: Date
    var source: SessionSource
    var createdAt: Date
}

struct RuntimeState: Codable {
    var trackingState: TrackingState
    var windowState: WindowState
    var activePosture: Posture?
    var activeSessionStartedAt: Date?
    var currentDayKey: String
    var lastRestoredAt: Date?
}

struct AlertState: Codable {
    var currentAlertKind: AlertKind?
    var alertTriggeredAt: Date?
    var snoozeUntil: Date?
    var lastDismissedAt: Date?
    var isAlertVisible: Bool
}
```

## 15. Validation Rules

The app should enforce these invariants:

1. At most one active posture session exists at a time.
2. `activePosture` must be nil when state is `setup` or `stopped`.
3. `activeSessionStartedAt` must be non-nil when state is active, alerting, snoozed, or locked.
4. `snoozeUntil` must be non-nil only when state is snoozed.
5. Completed sessions must never overlap in time.
6. Each completed session must belong to exactly one calendar day after midnight splitting.

## 16. Out Of Scope For MVP

The data model intentionally does not include:

- cloud account/user identity
- multi-device sync metadata
- team/shared reporting
- free-form notes on sessions
- break as a first-class posture type
- calorie tracking
