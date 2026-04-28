# Phase 2 Handoff

## Purpose

This document records what Phase 2 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and `PHASE-1-HANDOFF.md` for the domain model foundation.

## Phase 2 Scope

Phase 2 replaced the original single-column tracker screen with the MVP dashboard shell described in `STARTUP-UI.md`.

The focus was main-window structure and presentation. This phase did not implement editable settings, multi-day history, 7-day analytics, alert behavior, menu bar behavior, or screen-lock behavior.

## Files Changed

- `Sources/SitStandTracker/ContentView.swift`
- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- `PROJECT-PLAN.md`

## Completed

### App Launch Activation

`SitStandTrackerApp.swift` now includes an `NSApplicationDelegate` hook that:

- sets the activation policy to `.regular`
- activates the app when launched

This makes `swift run SitStandTracker` bring up the UI reliably when launched from Terminal.

The main window minimum size was increased to:

- width: `980`
- height: `680`

### Sidebar Navigation

`ContentView.swift` now includes a left navigation rail with:

- Dashboard
- History
- Analytics
- Settings

The selected page is stored locally in `ContentView` as:

```swift
@State private var selectedPage = AppPage.dashboard
```

### Dashboard Page

The Dashboard page now includes:

- page header
- current status card
- daily goal card
- four metric cards
- recent activity panel

The current status card supports:

- current posture
- active timer
- target ratio text
- start sitting
- start standing
- switch posture
- stop tracking

### Daily Goal Card

The goal card displays the current persisted work-cycle preferences from `TrackerStore`:

- standing block minutes
- sitting block minutes
- derived target ratio
- current goal status badge

The values are read-only for now. Editing belongs to Phase 3.

### Metrics Row

The dashboard now shows:

- Avg Sit
- Avg Stand
- Sit Streak
- Stand Streak

These values come from `trackerStore.todaySummary`.

### Recent Activity Panel

The dashboard now shows the newest completed sessions for today.

The `View All` action switches to the History page.

### History Page

The History page currently shows:

- today's sit/stand summary cards
- today's completed session list

This is intentionally still current-day only. Multi-day grouped history belongs to Phase 4.

### Analytics Page

The Analytics page currently shows:

- today's sitting/standing ratio bar
- total tracked time
- standing share
- current goal status

This is intentionally a current-day analytics surface only. Recent-day analytics belongs to Phase 5.

### Settings Page

The Settings page currently shows:

- current stand duration
- current sit duration
- current snooze duration
- reset data action

Preference editing belongs to Phase 3.

## Verified

`swift build` passed after Phase 2 changes.

The user also confirmed the app window appears after the launch activation fix.

## Intentionally Left Incomplete

### Editable Preferences

Preferences are displayed but cannot be edited from the UI yet.

Still missing:

- steppers or fields for stand duration
- steppers or fields for sit duration
- snooze duration control
- validation feedback
- dashboard goal-card editing

This belongs to Phase 3.

### Multi-Day History

History is still limited to today's sessions.

Still missing:

- day grouping
- newest-first day cards
- inline expansion
- prior-day summaries
- low-data status handling per day

This belongs to Phase 4.

### Recent-Day Analytics

Analytics is still limited to today's values.

Still missing:

- 7-day data range
- stacked bar chart across days
- counts of Met, Exceeded, Not Met, and Insufficient Data
- average active tracked time across days

This belongs to Phase 5.

### Menu Bar And Alerts

No menu bar or alert behavior was added in Phase 2.

These remain in Phases 6 and 7.

### Screen Lock And Day Boundary Rules

No screen-lock or midnight-splitting behavior was added in Phase 2.

These remain in Phase 9.

## Notes For Future Phases

### Phase 3

The Settings page already has a visual home for preferences.

Phase 3 can replace the read-only setting rows with controls that call:

```swift
trackerStore.updatePreferences(
    targetStandingBlockMinutes:targetSittingBlockMinutes:defaultSnoozeMinutes:
)
```

The dashboard goal card can also become editable in Phase 3.

### Phase 4

The History page already exists as a navigation destination.

Phase 4 should add store APIs for day grouping rather than calculating day summaries directly in `ContentView`.

### Phase 5

The Analytics page already has a ratio bar pattern for today.

Phase 5 should generalize this into a recent-days visualization backed by derived daily summaries.

### Phase 7

The current status card and action button composition can inform the normal menu bar panel.

The menu bar panel should still be implemented separately because it has tighter size and interaction constraints.

