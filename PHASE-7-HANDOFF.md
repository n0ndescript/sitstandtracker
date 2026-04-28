# Phase 7 Handoff

## Purpose

This document records what Phase 7 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and the prior phase handoff files for earlier implementation context.

## Phase 7 Scope

Phase 7 added the persistent menu bar companion.

The focus was menu bar presence, compact status labeling, normal tracking controls, alert controls, and a bridge back to the dashboard window. This phase did not implement close-to-menu-bar behavior, Dock hiding, screen-lock behavior, or midnight splitting.

## Files Changed

- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- `Sources/SitStandTracker/MenuBarView.swift`
- `PROJECT-PLAN.md`

## Completed

### Menu Bar Extra

`SitStandTrackerApp.swift` now creates a `MenuBarExtra` alongside the main `WindowGroup`.

The menu bar extra uses:

```swift
.menuBarExtraStyle(.window)
```

This allows the panel to host richer controls than a plain menu.

### Dashboard Window ID

The main window group now has the id:

```swift
"dashboard"
```

The menu bar panel uses `openWindow(id: "dashboard")` for the `Open Dashboard` action.

### Menu Bar Label

`MenuBarLabel` shows:

- alert state when an alert is visible
- active posture plus compact elapsed time when tracking
- idle state when no posture is active

Alert labels are direction-specific:

- `Stand!`
- `Sit!`

### Normal Panel

`MenuBarPanel` shows a normal tracking panel when no alert is visible.

The normal panel includes:

- current posture
- `ACTIVE SESSION` or `IDLE`
- large elapsed timer
- target ratio text
- optional snooze-until line
- switch/start controls
- stop tracking control
- today's current-posture total
- longest current-posture streak

When no posture is active, the panel shows start controls for sitting and standing.

### Alert Panel

When `trackerStore.activeAlertKind` is visible, the panel switches to an alert layout.

The alert panel includes:

- alert title
- direction-specific icon
- active posture elapsed time
- primary switch action
- snooze action
- dismiss action
- today's sit total
- today's stand total

Alert controls call:

- `trackerStore.switchToAlertRecommendation()`
- `trackerStore.snoozeAlert()`
- `trackerStore.dismissAlert()`

### Open Dashboard And Quit

The panel footer includes:

- `Open Dashboard`
- `Quit`

`Open Dashboard` opens/activates the dashboard window.

`Quit` calls:

```swift
NSApp.terminate(nil)
```

### Timer Updates

`MenuBarPanel` has its own one-second timer and calls:

```swift
trackerStore.tick()
```

This keeps alert evaluation and elapsed time moving while the menu bar panel is open.

## Verified

`swift build` passed after Phase 7 changes.

## Intentionally Left Incomplete

### Close-To-Menu-Bar Lifecycle

Closing the dashboard window may still follow the default app/window behavior.

Still missing:

- closing the window keeps the app running intentionally
- hiding the Dock icon when the dashboard is closed
- reopening behavior audit after close
- app lifecycle persistence audit before quit

This belongs to Phase 8.

### Menu Bar Timer While Panel Is Closed

The menu bar panel has its own timer while open. The dashboard also has a timer while open.

If both are closed or inactive, there is not yet a dedicated background timer owned by the app object.

Phase 8 should decide whether to add an app-level timer so alerts can trigger even when the dashboard window and menu bar panel are not open.

### Screen Lock

Menu bar behavior does not yet integrate with screen-lock suspend/resume.

This belongs to Phase 9.

### Alert Source Metadata

As noted in Phase 6, switching from an alert still uses the existing posture-switch path and does not yet mark the new active session as `SessionSource.alertSwitch`.

## Notes For Future Phases

### Phase 8

Phase 8 should build on:

- `WindowGroup("SitStandTracker", id: "dashboard")`
- `openWindow(id: "dashboard")`
- `MenuBarExtra`

The next lifecycle work should verify the app remains useful after the dashboard window is closed.

### Phase 9

Screen-lock handling should clear any visible or snoozed alert, close the active session, and resume the prior posture on unlock.

