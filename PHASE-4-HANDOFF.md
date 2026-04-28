# Phase 4 Handoff

## Purpose

This document records what Phase 4 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and the prior phase handoff files for earlier implementation context.

## Phase 4 Scope

Phase 4 made History a real day-grouped local archive.

The focus was day grouping, day-level summaries, goal status badges, and inline expansion. This phase did not implement recent-day analytics, historical preference snapshots, midnight session splitting, or export behavior.

## Files Changed

- `Sources/SitStandTracker/TrackerStore.swift`
- `Sources/SitStandTracker/ContentView.swift`
- `PROJECT-PLAN.md`

## Completed

### Day History Projection

`TrackerStore.swift` now includes:

```swift
struct DayHistory: Identifiable {
    let id: Date
    let date: Date
    let summary: DaySummary
    let sessions: [TrackingSession]
}
```

The store exposes:

```swift
var historyDays: [DayHistory]
```

`historyDays`:

- includes today even when there are no completed sessions
- includes any day with completed sessions
- includes the active session's start day if tracking is active
- sorts days newest first
- includes day-level `DaySummary`
- includes completed sessions sorted newest first

### Generalized Summary Helpers

The private summary helper now supports arbitrary days instead of only today.

This supports:

- current-day summary
- prior-day history summaries
- future analytics work

The active session is included in a day summary when the active session started on that day.

### History Page

The History page now shows day cards instead of only today's raw session list.

Each day card shows:

- date label
- completed session count
- goal status badge
- sitting total
- standing total
- standing share

### Inline Expansion

Each day card can expand inline to show completed sessions for that day.

The first/newest day is expanded when the History page appears. In normal use, that is Today.

### Goal Status Treatment

Day cards use the existing `statusBadge(for:)` treatment, so each status has:

- text
- color treatment

Supported statuses:

- Met
- Exceeded
- Not Met
- Insufficient Data

## Verified

`swift build` passed after Phase 4 changes.

## Intentionally Left Incomplete

### Midnight Splitting

History summaries still rely on session `startDate` to assign a completed session to a day.

Still missing:

- splitting completed sessions across midnight
- attributing partial session duration to each crossed day
- active-session overlap calculations for active sessions that began before midnight

This remains in Phase 9.

### Historical Preference Snapshots

Goal status for every day is evaluated against the current preferences.

This matches the current MVP data model, but it means changing the work cycle can change status labels for prior days.

If historically stable day ratings become important, the app should store preference snapshots per day or per session.

### Analytics

The store now has day history data that Phase 5 can reuse, but Phase 4 did not implement:

- 7-day analytics range
- recent-day stacked bar chart
- counts by goal status
- average tracked time across days

### Active In-Progress Session Rows

History includes active-session time in day totals, but expanded day rows show completed sessions only.

This matches the existing session model: in-progress tracking is runtime state, not a completed `TrackingSession`.

## Notes For Future Phases

### Phase 5

Analytics should start with `trackerStore.historyDays`.

Potential useful additions:

```swift
func historyDays(limit: Int) -> [DayHistory]
```

or:

```swift
func summariesForRecentDays(count: Int) -> [DayHistory]
```

If the 7-day chart should include empty days with zero time, Phase 5 will need a helper that generates calendar days even when there are no sessions.

### Phase 9

The current arbitrary-day summary helper is the right place to add day-overlap and midnight-splitting behavior.

When Phase 9 is implemented, verify:

- completed sessions spanning midnight
- active sessions spanning midnight
- locked-time exclusion
- history day totals before and after midnight

