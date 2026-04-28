# Phase 5 Handoff

## Purpose

This document records what Phase 5 completed, what remains incomplete, and what later phases can reuse.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and the prior phase handoff files for earlier implementation context.

## Phase 5 Scope

Phase 5 made Analytics a 7-day recent-ratio view.

The focus was derived analytics over local session data. This phase did not implement alerts, menu bar behavior, screen-lock behavior, midnight splitting, or chart range controls.

## Files Changed

- `Sources/SitStandTracker/TrackerStore.swift`
- `Sources/SitStandTracker/ContentView.swift`
- `PROJECT-PLAN.md`

## Completed

### Analytics Summary Model

`TrackerStore.swift` now includes:

```swift
struct AnalyticsSummary {
    let days: [DayHistory]
    let metCount: Int
    let exceededCount: Int
    let notMetCount: Int
    let insufficientDataCount: Int
    let averageActiveTrackedDuration: TimeInterval
    let averageSitDuration: TimeInterval
    let averageStandDuration: TimeInterval
}
```

The store exposes:

```swift
var sevenDayAnalytics: AnalyticsSummary
func analyticsSummaryForRecentDays(count: Int) -> AnalyticsSummary
```

### Seven-Day Range

The analytics helper generates a fixed recent-day range ending today.

For the MVP page, `sevenDayAnalytics` uses:

```swift
analyticsSummaryForRecentDays(count: 7)
```

The generated days are sorted oldest to newest for chart display.

Empty days are included, so the chart always covers the last 7 calendar days.

### Stacked Bar View

The Analytics page now includes a `Recent Ratio` section with one row per day.

Each row shows:

- day label
- sitting duration segment
- standing duration segment
- total tracked duration
- standing share
- goal status badge

The bars are scaled against the largest tracked duration in the 7-day range.

### Status Counts

The Analytics page now shows counts for:

- Met
- Exceeded
- Not Met
- Low Data

`Low Data` maps to `GoalStatus.insufficientData`.

### Averages

The Analytics page now shows:

- average active tracked time
- average completed sitting session length
- average completed standing session length

Average active tracked time ignores zero-duration days.

Average sit and stand values use completed sessions in the 7-day range.

## Verified

`swift build` passed after Phase 5 changes.

## Intentionally Left Incomplete

### Range Controls

The MVP default is fixed to 7 days.

Still missing:

- 14-day view
- custom date range
- range picker

These are intentionally out of scope for the current MVP.

### Historical Preference Snapshots

Goal statuses are still evaluated against current preferences.

Changing the work-cycle preferences can change analytics statuses for prior days.

This caveat also applies to History.

### Midnight Splitting

Analytics relies on the same day-summary logic as History.

Still missing:

- completed-session overlap across midnight
- active-session overlap across midnight

This remains in Phase 9.

### Chart Interactivity

The chart is static.

Still missing:

- hover details
- selected day drilldown
- keyboard navigation for chart bars

These are not required for the current MVP.

## Notes For Future Phases

### Phase 6

The alert engine can use `sevenDayAnalytics` only as a reporting surface; it should not depend on analytics state for threshold behavior.

Alert logic should remain in `TrackerStore` and derive from active runtime state plus preferences.

### Phase 9

When day-boundary splitting is implemented, verify that `sevenDayAnalytics` updates correctly for:

- sessions crossing midnight
- active sessions crossing midnight
- locked time excluded from summaries

