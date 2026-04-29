# SitStandTracker Final Decisions

## Purpose

This document captures the remaining product decisions needed to treat the MVP spec as complete.

## 1. Goal Status Tolerance

Approved default:

- `Met` = within `+/- 5 percentage points`
- `Exceeded` = above that band
- `Not Met` = below that band

Example:

If the target standing share is `25%`:

- `20%` to `30%` => `Met`
- above `30%` => `Exceeded`
- below `20%` => `Not Met`

## 2. Reset Scope

Approved default:

`Reset data` deletes:

- all session history
- current runtime state
- alert state

It preserves:

- work-cycle preferences
- snooze preference

## 3. Analytics Default Range

Approved default:

- default range: `7 days`
- no range switcher in MVP

## 4. Low-Data Day Handling

Approved default:

If total active tracked time for a day is less than `30 minutes`:

- do not assign `Met`, `Exceeded`, or `Not Met`
- show `Insufficient Data`

## 5. History Interaction Pattern

Approved default:

- one-page history view
- newest day first
- each day shown as a summary card
- clicking a day expands inline to show its session list

## 6. Menu Bar Icon Language

Approved default:

Normal states:

- `sitting`: seated icon + compact timer
- `standing`: standing icon + compact timer

Alert states:

- `time_to_stand`: seated icon with alert accent or badge
- `time_to_sit`: standing icon with alert accent or badge

Accessibility rule:

- alert differences must not rely on color alone
- icon, badge, or symbol change must also indicate direction

## 7. Manual Pause

Approved default:

- No manual `Pause` in MVP
- The only explicit control is `Stop Tracking`
- Screen lock remains the only automatic suspend/resume behavior

## 8. Close vs Quit App Behavior

Approved default:

- closing the main window keeps the app running in the menu bar
- closing the main window hides the app from the Dock
- reopening from the menu bar shows the window again
- quitting removes the app from the menu bar and ends the process after persisting data

Recommended supporting copy:

- `Closing the window keeps tracking active in the menu bar and hides the app from the Dock.`

## 9. Approved MVP Set

1. `Met` tolerance = `+/- 5 percentage points`
2. `Reset data` clears history and runtime state but preserves preferences
3. Analytics default range = `7 days`
4. `< 30 minutes` active tracked time = `Insufficient Data`
5. History uses inline expandable day cards
6. Menu bar states use both icon/state and color differences
7. No manual `Pause` in MVP
8. Close keeps menu bar alive, hides the Dock icon, and quit persists data before exiting
