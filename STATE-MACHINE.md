# SitStandTracker State Machine

## 1. Purpose

This document defines the canonical runtime state model for SitStandTracker. It covers posture tracking, menu bar alert behavior, screen-lock behavior, window visibility, quit behavior, and day-boundary rollover.

## 2. State Model Overview

The app uses two parallel state dimensions:

1. `TrackingState`
2. `WindowState`

Closing the window does not stop tracking.

## 3. TrackingState

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

### 3.1 `setup`

- the app is launched for a day with no usable saved preferences or no prior day context
- the user confirms the work-cycle pair
- on completion, enter `active_sitting`

### 3.2 `active_sitting`

- sitting is the active posture
- sitting timer is running
- menu bar is visible while app is running

Exit events:

- user switches to standing
- sitting threshold is reached
- screen locks
- user stops tracking
- user quits app

### 3.3 `active_standing`

- standing is the active posture
- standing timer is running
- menu bar is visible while app is running

Exit events:

- user switches to sitting
- standing threshold is reached
- screen locks
- user stops tracking
- user quits app

### 3.4 `locked_sitting`

- the screen is locked while the user had been sitting
- the current sitting segment is closed at lock time
- tracking is temporarily suspended

Semantics:

- locked time does not count toward totals, ratios, streaks, or alerts
- unlocking automatically resumes a new sitting session

### 3.5 `locked_standing`

- the screen is locked while the user had been standing
- the current standing segment is closed at lock time
- tracking is temporarily suspended

Semantics:

- locked time does not count toward totals, ratios, streaks, or alerts
- unlocking automatically resumes a new standing session

### 3.6 `alert_time_to_stand`

- the user has been sitting longer than the configured sitting threshold
- the menu bar icon enters the sit-to-stand alert visual state

Exit events:

- user switches to standing
- user snoozes
- user dismisses
- screen locks
- user stops tracking
- user quits app

### 3.7 `alert_time_to_sit`

- the user has been standing longer than the configured standing threshold
- the menu bar icon enters the stand-to-sit alert visual state

Exit events:

- user switches to sitting
- user snoozes
- user dismisses
- screen locks
- user stops tracking
- user quits app

### 3.8 `snoozed_sitting`

- the user was prompted to stand
- the user chose snooze or dismiss
- sitting remains the active posture
- the alert is temporarily suppressed until rearm time

### 3.9 `snoozed_standing`

- the user was prompted to sit
- the user chose snooze or dismiss
- standing remains the active posture
- the alert is temporarily suppressed until rearm time

### 3.10 `stopped`

- app is still running
- no active posture session exists
- menu bar item remains visible

Exit events:

- user starts sitting
- user starts standing
- user quits app

## 4. WindowState

Allowed values:

- `visible`
- `hidden_to_menubar`
- `quit`

### 4.1 `visible`

- the dashboard window is open
- the app may appear in the Dock

### 4.2 `hidden_to_menubar`

- the main window is closed or hidden
- app remains running
- menu bar item remains visible
- the Dock icon is hidden
- tracking continues in the current `TrackingState`

### 4.3 `quit`

- app is fully terminated
- no menu bar item remains

## 5. Launch Rules

### 5.1 First-Ever Launch

If the app has never been used before:

- enter `TrackingState = setup`
- enter `WindowState = visible`

After setup is completed:

- create a default active sitting session
- enter `TrackingState = active_sitting`

### 5.2 Relaunch On The Same Day

If the app is launched and saved data exists for the current local day:

- restore prior day data
- restore the last persisted `TrackingState`
- restore any active session if one exists
- set `WindowState = visible`

Examples:

- `active_standing` restores `active_standing`
- `stopped` restores `stopped`
- `snoozed_sitting` restores if snooze is still valid
- `locked_sitting` restores as `locked_sitting` only if the screen is still locked; otherwise restore `active_sitting`

### 5.3 Launch On A New Day

If the app is launched on a new local day:

- load prior saved preferences
- do not carry forward prior daily totals as today’s totals
- create a fresh day context

If saved preferences exist:

- do not show setup again

If saved preferences do not exist:

- enter `TrackingState = setup`

If an active posture spans the day boundary:

- restore the active posture
- split session accounting across midnight
- continue in the corresponding active state

If no active session was in progress and preferences exist:

- enter `TrackingState = active_sitting`

If the app was stopped before quit and the new day starts:

- restore `stopped`

## 6. Day Boundary Rule

At `12:00 AM` local time:

- the previous day is closed
- completed time up to midnight is attributed to the prior day
- a new day begins for reporting and totals

If an active posture crosses midnight:

- the session is logically split across the boundary
- prior-day duration is credited to the prior day
- post-midnight duration is credited to the new day
- the user remains in the same posture state

This means:

- daily totals reset
- current posture does not reset
- target ratio preferences persist
- stopped state remains stopped

## 7. Canonical Event Transitions

### 7.1 Setup

- `setup` + `complete_setup` -> `active_sitting`

### 7.2 Manual Start And Resume

- `stopped` + `start_sitting` -> `active_sitting`
- `stopped` + `start_standing` -> `active_standing`
- `locked_sitting` + `screen_unlocked` -> `active_sitting`
- `locked_standing` + `screen_unlocked` -> `active_standing`

### 7.3 Manual Switch

- `active_sitting` + `switch_to_standing` -> `active_standing`
- `active_standing` + `switch_to_sitting` -> `active_sitting`
- `alert_time_to_stand` + `switch_to_standing` -> `active_standing`
- `alert_time_to_sit` + `switch_to_sitting` -> `active_sitting`
- `snoozed_sitting` + `switch_to_standing` -> `active_standing`
- `snoozed_standing` + `switch_to_sitting` -> `active_sitting`

### 7.4 Threshold Events

- `active_sitting` + `sitting_threshold_reached` -> `alert_time_to_stand`
- `active_standing` + `standing_threshold_reached` -> `alert_time_to_sit`

### 7.5 Snooze And Dismiss Events

- `alert_time_to_stand` + `snooze` -> `snoozed_sitting`
- `alert_time_to_sit` + `snooze` -> `snoozed_standing`
- `alert_time_to_stand` + `dismiss_alert` -> `snoozed_sitting`
- `alert_time_to_sit` + `dismiss_alert` -> `snoozed_standing`
- `snoozed_sitting` + `rearm_expired_and_still_sitting` -> `alert_time_to_stand`
- `snoozed_standing` + `rearm_expired_and_still_standing` -> `alert_time_to_sit`

### 7.6 Stop Events

- `active_sitting` + `stop_tracking` -> `stopped`
- `active_standing` + `stop_tracking` -> `stopped`
- `alert_time_to_stand` + `stop_tracking` -> `stopped`
- `alert_time_to_sit` + `stop_tracking` -> `stopped`
- `snoozed_sitting` + `stop_tracking` -> `stopped`
- `snoozed_standing` + `stop_tracking` -> `stopped`
- `locked_sitting` + `stop_tracking` -> `stopped`
- `locked_standing` + `stop_tracking` -> `stopped`

### 7.7 Screen Lock Events

- `active_sitting` + `screen_locked` -> `locked_sitting`
- `active_standing` + `screen_locked` -> `locked_standing`
- `alert_time_to_stand` + `screen_locked` -> `locked_sitting`
- `alert_time_to_sit` + `screen_locked` -> `locked_standing`
- `snoozed_sitting` + `screen_locked` -> `locked_sitting`
- `snoozed_standing` + `screen_locked` -> `locked_standing`

Screen-lock semantics:

- close the active posture segment at lock time
- clear current alert state
- clear current snooze state
- do not count locked time toward active tracked ratios
- automatically resume the prior posture on unlock

### 7.8 Quit Events

- any `TrackingState` + `quit_app` -> persisted shutdown
- any `WindowState` + `quit_app` -> `quit`

## 8. WindowState Transitions

- `visible` + `close_window` -> `hidden_to_menubar`
- `hidden_to_menubar` + `open_dashboard` -> `visible`
- `visible` + `quit_app` -> `quit`
- `hidden_to_menubar` + `quit_app` -> `quit`

Closing the window must never change `TrackingState`.

## 9. Persistence Requirements

At minimum, persist:

- current `TrackingState`
- current posture if active or locked
- active session start time
- completed sessions for the current day
- user goal preferences
- snooze expiry if snoozed
- date key for the day context

The app must persist data before quit completes.

## 10. Explicit Non-Rules

- closing the window does not stop tracking
- midnight does not force the posture back to sitting
- screen lock suspends tracking and auto-resumes the same posture on unlock
- closing the window hides the Dock icon while the app keeps running in the menu bar
- quitting the app removes it from the menu bar
- same-day relaunch does not start from scratch

## 11. Resolved Decisions

- there is no manual `Pause` state in MVP
- screen lock is the automatic suspend flow
- locked time does not count toward posture totals, ratios, streaks, or alerts
- unlocking from screen lock starts a new posture session in the same prior posture
- dismiss is not permanent; in MVP it rearms on the same interval as snooze
- setup is only shown when required preferences do not exist
- on a new day with preferences but no active prior session, the app defaults to `active_sitting`
