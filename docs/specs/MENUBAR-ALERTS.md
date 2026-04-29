# SitStandTracker Menu Bar Alerts

## Purpose

Define how the app behaves when the user has stayed in the current posture longer than their configured transition threshold.

## Core Behavior

The app is always present in the menu bar while running.

When the user exceeds a configured threshold:

- the menu bar item changes visual state
- the visual change depends on the transition being requested
- clicking the menu bar item opens an action-oriented alert panel

This behavior is not just a passive notification. It is the primary real-time intervention mechanism for the app.

## Transition Types

There are two distinct threshold events.

### 1. Time To Stand

Trigger:

- the user has been sitting longer than their configured sitting threshold

Meaning:

- the app is asking the user to move from sitting to standing

Suggested treatment:

- warmer or more urgent accent
- title: `Time to Stand`
- primary action: `Switch to Standing`

### 2. Time To Sit

Trigger:

- the user has been standing longer than their configured standing threshold

Meaning:

- the app is asking the user to move from standing to sitting

Suggested treatment:

- cooler or different accent from the standing prompt
- title: `Time to Sit`
- primary action: `Switch to Sitting`

## Menu Bar States

### Normal State

The menu bar item shows:

- current posture indicator
- compact elapsed time

Examples:

- `stand 01:24`
- `sit 00:42`

Clicking the menu bar item in the normal state should open a compact control panel with:

- current posture heading
- active-session label
- large timer
- target ratio line
- switch action
- stop-tracking action
- today's current-posture total
- longest streak

This panel is the default non-alert interaction.

### Alert State

The menu bar item should change when a threshold is hit.

It can change by:

- accent color
- icon badge
- outline or fill treatment
- symbol swap

Requirements:

- `Time to Stand` and `Time to Sit` must not look identical
- the user should infer the needed direction from the menu bar alone
- the alert should be noticeable but should not feel like an error state

## Alert Panel Layout

The alert panel should contain:

1. Alert title
2. Dismiss icon
3. Large timer
4. Explanatory sentence
5. Primary switch button
6. Snooze button
7. Dismiss button
8. Today's totals footer

## Normal Panel Layout

Using the provided non-alert example, the default panel should look conceptually like:

- Header:
  - posture label such as `Standing`
  - session subtitle such as `ACTIVE SESSION`
  - overflow menu affordance
- Body:
  - large timer such as `00:01`
  - goal text such as `Target ratio: 1 stand / 3 sit`
- Actions:
  - `Switch to Sitting` or `Switch to Standing`
  - `Stop Tracking`
- Footer:
  - today's total for the active posture
  - longest streak

This normal panel should feel cleaner and quieter than the threshold alert panel.

## Reference Structure

Using the provided example, the panel should look conceptually like:

- Header:
  - `Time to Stand`
  - close or dismiss affordance
- Body:
  - large `00:00` style timer
  - sentence like `You've been sitting for 60 minutes.`
- Primary action:
  - `Switch to Standing`
- Secondary actions:
  - `+5 min`
  - `Dismiss`
- Footer:
  - today's sit total
  - today's stand total

## Interaction Rules

### Primary Action

When the user taps the primary transition button:

- close the current session
- create a new session for the opposite posture
- clear the alert state
- return the menu bar to its normal tracking state

### Snooze

When the user taps `+5 min`:

- keep the current session active
- defer the alert by five minutes
- keep tracking time continuously

### Dismiss

When the user dismisses the alert:

- hide the current alert panel
- keep the current session active
- allow a later alert to reappear according to app rules

## Recommended MVP Rules

1. Keep snooze fixed at `+5 min`.
2. Support one active alert at a time.
3. Re-show an alert after snooze expiry if the posture still has not changed.
4. Use local preferences from the dashboard goal card for threshold timing and ratio derivation.
5. Avoid separate macOS notification banners in the MVP unless needed later.

## Design Tone

The alert should feel:

- clear
- time-sensitive
- lightweight
- productivity-oriented

It should not feel:

- medical
- punitive
- error-like
- overly animated
