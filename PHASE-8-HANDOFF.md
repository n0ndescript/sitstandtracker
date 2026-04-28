# Phase 8 Handoff

## Purpose

This document records what Phase 8 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and the prior phase handoff files for earlier implementation context.

## Phase 8 Scope

Phase 8 tightened the app lifecycle for the hybrid dashboard plus menu bar model.

The focus was close-to-menu-bar behavior, dashboard reopening, quit persistence, Dock activation behavior, and background ticking while the app process remains alive.

This phase did not implement screen-lock handling or midnight session splitting.

## Files Changed

- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- `Sources/SitStandTracker/MenuBarView.swift`
- `Sources/SitStandTracker/ContentView.swift`
- `Sources/SitStandTracker/TrackerStore.swift`
- `PROJECT-PLAN.md`

## Completed

### Single Dashboard Window

The dashboard scene remains a single SwiftUI `Window` with id:

```swift
"dashboard"
```

This prevents `Open Dashboard` from spawning multiple dashboard windows.

### App Delegate Lifecycle Hooks

`AppDelegate` now implements:

```swift
applicationShouldTerminateAfterLastWindowClosed(_:)
applicationWillTerminate(_:)
```

`applicationShouldTerminateAfterLastWindowClosed(_:)` returns `false`, so closing the dashboard window does not quit the app.

`applicationWillTerminate(_:)` calls a stored `prepareForQuit` closure and synchronizes `UserDefaults`.

### Quit Persistence

`TrackerStore` now exposes:

```swift
func prepareForQuit()
```

The dashboard registers this with the app delegate on appear.

Because the store already persists important state when tracking changes, this is mostly a final safety flush before app termination.

### Dock Activation Behavior

The app delegate observes dashboard window notifications.

When the dashboard window closes:

```swift
NSApp.setActivationPolicy(.accessory)
```

This hides the Dock presence while the app remains available from the menu bar.

When the dashboard window becomes key again:

```swift
NSApp.setActivationPolicy(.regular)
```

This restores normal app activation.

### Open Dashboard Behavior

The menu bar `Open Dashboard` action now:

1. sets activation policy to `.regular`
2. calls `openWindow(id: "dashboard")`
3. activates the app

This is intended to bring back the existing single dashboard window from the menu bar.

### App-Level Ticker

`TrackerStore` now owns an internal one-second timer.

This means:

- elapsed time advances while the app process is alive
- alert evaluation continues even if the dashboard window is closed
- menu bar label/panel can observe store time without owning their own timer

The duplicate timers in `ContentView` and `MenuBarPanel` were removed.

### Main Actor Isolation

`AppDelegate` and `TrackerStore` are now `@MainActor`.

The store timer uses a selector-based helper object rather than a timer closure, avoiding Swift 6 sendability warnings.

## Verified

`swift build` passed after Phase 8 changes.

## Intentionally Left Incomplete

### Screen Lock

The app does not yet observe screen lock or unlock.

Still missing:

- closing active sessions at lock time
- entering locked sitting/standing states
- clearing alert and snooze state on lock
- resuming the prior posture on unlock

This belongs to Phase 9.

### Midnight Splitting

Daily accounting still assigns sessions by start date.

This remains in Phase 9.

### Manual Smoke Test

The build passes, but lifecycle behavior should be manually verified in the running app:

- close dashboard, confirm app remains in menu bar
- confirm Dock icon hides after dashboard close
- reopen dashboard from menu bar
- confirm no duplicate dashboard window appears
- quit from menu bar
- relaunch and confirm active/stopped state restores

### Dashboard Window Identification

Dock hiding currently identifies the dashboard window by title:

```swift
"SitStandTracker"
```

If the window title changes in a future UI pass, this lifecycle hook should be updated.

## Notes For Future Phases

### Phase 9

Screen lock handling should integrate with the app-level lifecycle and `TrackerStore`.

Likely store APIs:

```swift
func handleScreenLocked()
func handleScreenUnlocked()
```

Lock should clear alert/snooze state and close the active session. Unlock should resume the previous posture in a new session.

### Phase 10

The README should be updated with the current launch behavior and the recommended command:

```bash
swift run SitStandTracker
```

