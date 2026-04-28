# SitStandTracker Page Specs

## 1. Purpose

This document defines the MVP product surfaces beyond the state machine and raw data model.

It captures the concrete decisions for:

- `Dashboard`
- `History`
- `Analytics`
- `Settings`

## 2. Shared Decisions

### 2.1 Cycle Goal Model

The app uses one paired work-cycle setting:

- stand for `X` minutes
- after sitting for `Y` minutes

This single pair drives:

- sit-to-stand alerts
- stand-to-sit alerts
- daily target ratio

### 2.2 Ratio Goal Interpretation

The app does not use a fixed standing-minutes-per-day goal.

Instead:

- target sit share = `Y / (X + Y)`
- target stand share = `X / (X + Y)`

Example:

- stand `15`
- sit `45`
- target ratio = `1:3 stand/sit`
- target standing share = `25%`

### 2.3 Daily Goal Status

Every tracked day gets one of three statuses:

- `Met`
- `Exceeded`
- `Not Met`

Meaning:

- `Met`
  - actual standing share is within `+/- 5 percentage points` of target standing share
- `Exceeded`
  - actual standing share is above the tolerance band
- `Not Met`
  - actual standing share is below the tolerance band

These statuses must use both text labels and visual treatment.

## 3. Dashboard

The dashboard is the primary working surface.

### Content

- left sidebar
- current status card
- goal card
- four summary tiles
- recent activity list

### Tile Set

The MVP dashboard tiles are:

- `Avg Sit`
- `Avg Stand`
- `Sit Streak`
- `Stand Streak`

### Streak Definition

- `Sit Streak`
  - longest sitting segment for the current day
- `Stand Streak`
  - longest standing segment for the current day

## 4. History

The history page is a local archive of prior tracked days.

### Structure

- day-grouped cards or rows
- default sort: newest day first
- default entry point: `Today`

### Day Summary

Each day summary should show:

- date
- total sitting time
- total standing time
- ratio summary
- day status badge

### Visual Treatment Decision

Recommended MVP treatment:

- `Met`
  - green badge or green-accent border
- `Exceeded`
  - blue badge or blue-accent border
- `Not Met`
  - amber badge or amber-accent border

## 5. Analytics

The analytics page stays in MVP, but it should remain narrow and useful.

### Purpose

Help the user understand whether they are roughly honoring their intended sit/stand rhythm over time.

### Content

- recent-days ratio chart
- counts of `Met`, `Exceeded`, and `Not Met` days
- average active tracked time
- average sit session length
- average stand session length

### Recommended Chart

Use a 7-day or 14-day stacked bar view:

- sitting time
- standing time
- target standing share reference

## 6. Settings

The settings page should stay small and practical.

### Controls

- `Stand for X minutes`
- `After Y minutes of sitting`
- `Default snooze minutes`
- `Reset data`

### Locked-Screen Behavior

Screen-lock auto-stop / unlock auto-resume is a fixed MVP behavior, not a user-configurable setting.

## 7. Menu Bar Implications

Because the goal is ratio-based:

- the normal menu bar panel should show target ratio text
- it should not show `2 hrs remaining` style copy

Recommended copy:

- `Target ratio: 1 stand / 3 sit`

## 8. Mockups

- Dashboard: [startup-dashboard-reference.svg](/Users/siddharthv/code/the-archaeologist/mac/SitStandTracker/mockups/startup-dashboard-reference.svg)
- History: [history-mockup.svg](/Users/siddharthv/code/the-archaeologist/mac/SitStandTracker/mockups/history-mockup.svg)
- Analytics: [analytics-mockup.svg](/Users/siddharthv/code/the-archaeologist/mac/SitStandTracker/mockups/analytics-mockup.svg)
- Settings: [settings-mockup.svg](/Users/siddharthv/code/the-archaeologist/mac/SitStandTracker/mockups/settings-mockup.svg)
