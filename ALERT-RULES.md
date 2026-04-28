# SitStandTracker Alert Rules

## 1. Purpose

This document defines the operational rules for posture transition alerts in SitStandTracker.

It answers:

- when an alert should trigger
- when it should be visible
- when it should stop
- how snooze and dismiss behave
- how alerts behave across relaunch, stop, screen lock, and midnight

## 2. Alert Philosophy

Alerts are the app’s primary intervention mechanism, but they should remain lightweight.

Alerts should be:

- timely
- unambiguous
- recoverable
- easy to postpone

Alerts should not:

- feel punitive
- stack into multiple competing warnings
- permanently silence tracking behavior

## 3. Alert Types

The MVP supports exactly two alert types.

### 3.1 `time_to_stand`

Triggered when:

- the user is currently sitting
- the sitting threshold is reached or exceeded

Primary action:

- `Switch to Standing`

### 3.2 `time_to_sit`

Triggered when:

- the user is currently standing
- the standing threshold is reached or exceeded

Primary action:

- `Switch to Sitting`

## 4. Trigger Conditions

An alert may trigger only if all of the following are true:

1. the app is running
2. the app is not quit
3. the user is in an active posture state
4. the relevant threshold duration has been reached
5. there is no active snooze suppressing the alert

## 5. Visibility Rules

When an alert is active:

- the menu bar icon changes to the alert state
- clicking the menu bar icon opens the alert panel
- the app does not need a separate macOS notification banner in MVP

When an alert first triggers:

- the alert state becomes active immediately
- the menu bar icon visibly changes immediately
- the alert panel does not auto-open in MVP

## 6. Alert Panel Content

The alert panel must show:

1. alert title
2. close or dismiss affordance
3. large timer
4. explanatory sentence
5. primary switch action
6. snooze action
7. dismiss action
8. today's totals footer

### Title Rules

- `time_to_stand` -> `Time to Stand`
- `time_to_sit` -> `Time to Sit`

## 7. Rearm Model

The app supports one active alert context at a time.

Alerts do not stack.

If the user remains in the same posture after an alert has been snoozed or dismissed:

- the alert may rearm after the rearm interval expires

### Rearm Interval

For MVP:

- the rearm interval is the same as `defaultSnoozeMinutes`
- default value: `5 minutes`

## 8. Snooze Rules

When the user taps `+5 min`:

- keep the current posture active
- keep the current session running
- hide the visible alert panel
- enter the matching snoozed state

When snooze expires:

- if the user is still in the same posture, re-enter the relevant alert state
- if the user already switched posture, do nothing
- if tracking was stopped or screen-locked, do nothing

## 9. Dismiss Rules

When the user taps `Dismiss` or closes the alert panel using the dismiss affordance:

- keep the current posture active
- keep the current session running
- hide the visible alert panel
- do not permanently silence alerts

For MVP:

- `Dismiss` and `+5 min` both postpone the next alert by 5 minutes
- the difference is semantic intent, not underlying timing behavior

## 10. Primary Action Rules

When the user taps the primary switch button:

- end the current posture session at the action timestamp
- create a new session for the opposite posture
- clear the current alert state
- clear any snooze state
- return the menu bar icon to the normal non-alert state

## 11. Stop And Screen Lock

### Stop Tracking

If the user stops tracking while an alert is active or snoozed:

- end the active posture session
- clear alert state
- clear snooze state
- enter `stopped`

### Screen Lock

If the screen locks while an alert is active or snoozed:

- end the active posture segment at lock time
- clear alert state
- clear snooze state
- enter the matching locked state for the current posture

When the screen unlocks:

- automatically start a new session in the same posture
- do not restore the prior visible alert immediately unless the new resumed segment later reaches threshold again

## 12. Relaunch Rules

### Same-Day Relaunch

If the app is quit and relaunched on the same day:

- restore current alert or snooze state if still valid
- restore menu bar visual state accordingly

### Expired Snooze On Relaunch

If the app relaunches after a snooze expiry time has already passed:

- immediately evaluate the current posture and threshold
- if still overdue, restore the relevant alert state

## 13. Midnight Rules

At the local day boundary:

- alert logic continues based on the active posture
- crossing midnight does not clear an overdue posture condition by itself

Daily totals reset, but alert eligibility is based on the continuous active posture segment.

Screen-locked time is not part of the continuous active posture segment because the active segment is closed at lock time.

## 14. Accessibility Rules

Alert distinction must not rely on color alone.

The app should differentiate `time_to_stand` and `time_to_sit` using at least one of:

- different symbols
- different labels
- different icon shapes or badges

## 15. Explicit Non-Rules

The MVP alert system does not:

- produce multiple simultaneous alert records
- support custom snooze durations
- show system notification banners by default
- permanently dismiss alerts for the day
- suppress alerts just because the main window is hidden
- continue posture timing while the screen is locked
